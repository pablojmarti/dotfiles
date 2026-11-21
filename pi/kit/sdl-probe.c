/* sdl-probe.c: a probe that sits between an SDL3 game and SDL.
 *
 * scripts/play-check.sh builds this file as a shared library and loads it
 * into the game with LD_PRELOAD (Linux only). The game's code is not changed.
 * The probe replaces a few SDL functions with its own versions, which do
 * their job and then call the real ones:
 *
 *   - drawing calls: each rectangle, texture and debug text is written to
 *     a trace file, with the frame number and the position in window pixels
 *   - SDL_RenderPresent: counts frames, saves pictures, ends the run
 *   - the clock: every frame is exactly 1/PLAY_FPS seconds of game time,
 *     so a run always gives the same result and takes no real time
 *   - the keyboard and mouse: keys, clicks and typed words come from
 *     PLAY_KEYS, not from a person
 *
 * Settings (environment variables, set by play-check.sh):
 *   PLAY_OUT     folder for trace.tsv and the pictures   (build/play)
 *   PLAY_FRAMES  frames to run before stopping the game   (3600)
 *   PLAY_FPS     frames per second of game time           (60)
 *   PLAY_KEYS    the input plan, entries separated by spaces:
 *                  W:10-120          hold W from frame 10 to frame 120
 *                  R:500             tap R at frame 500 (down for two frames)
 *                  click:400,300:90  click the left mouse button at window
 *                                    pixel (400,300) at frame 90
 *                  type:help:200     type the word "help", one key tap every
 *                                    two frames from frame 200 (key events
 *                                    only, no text-input events)
 *                Key names are SDL's key names.
 *   PLAY_SHOTS   frames to save as pictures, e.g. "1 300 599". The probe also
 *                saves one picture two frames after every entry in the plan
 *                starts (after the last letter, for a typed word).
 *
 * Trace lines (tab separated):
 *   W  width  height                      window size in pixels
 *   R  frame  x  y  w  h                  a rectangle
 *   T  frame  x  y  w  h                  a texture (an image, or TTF text)
 *   X  frame  x  y  w  h  text            debug text
 *   P  frame                              the frame was shown
 *   N  note                               something the probe could not do
 *   END  frames  limit|exit               why the trace ends
 *
 * Every SDL function is looked up by name at run time, so this library has
 * no link to SDL and loads harmlessly into programs that do not use SDL
 * (the shell that starts the game, for one).
 */
#define _GNU_SOURCE
#include <SDL3/SDL.h>
#include <dlfcn.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_INPUTS 256
#define MAX_SHOTS  (16 + MAX_INPUTS)

static FILE  *trace;
static bool   ready;
static bool   size_written;
static long   frame;
static long   max_frames = 3600;
static long   fps        = 60;
static Uint64 clock_ns;
static float  scale_x = 1.0f, scale_y = 1.0f;
static char   out_dir[512] = "build/play";

static bool keys[SDL_SCANCODE_COUNT];
/* One entry of the input plan: a key held from one frame to another, or a
 * mouse click (down at `from`, up after `to`). */
static struct {
    bool         click;
    bool         down;
    SDL_Scancode code;
    SDL_Keymod   mod;
    float        x, y;
    long         from, to;
} plan[MAX_INPUTS];
static int   plan_count;
static float mouse_x, mouse_y;
static bool  mouse_down;
static long  shots[MAX_SHOTS];
static int   shot_count;

/* Find the real SDL function called `name`. */
static void *real(const char *name) {
    void *p = dlsym(RTLD_NEXT, name);
    if (p == NULL) {
        fprintf(stderr, "sdl-probe: cannot find %s in SDL\n", name);
        _exit(97);
    }
    return p;
}

static void note(const char *what, const char *detail) {
    if (trace != NULL) {
        fprintf(trace, "N\t%s%s%s\n", what, detail ? ": " : "", detail ? detail : "");
    }
}

/* Runs when the game ends by itself (return from main, or exit). */
static void game_ended(void) {
    if (trace != NULL) {
        fprintf(trace, "END\t%ld\texit\n", frame);
        fclose(trace);
        trace = NULL;
    }
}

static void add_shot(long f) {
    if (shot_count < MAX_SHOTS) {
        shots[shot_count++] = f;
    }
}

/* Add one plan entry. Returns false when the plan is full. */
static bool add_input(bool click, SDL_Scancode code, SDL_Keymod mod, float x, float y,
                      long from, long to) {
    if (plan_count >= MAX_INPUTS) {
        return false;
    }
    plan[plan_count].click = click;
    plan[plan_count].down  = false;
    plan[plan_count].code  = code;
    plan[plan_count].mod   = mod;
    plan[plan_count].x     = x;
    plan[plan_count].y     = y;
    plan[plan_count].from  = from;
    plan[plan_count].to    = to;
    plan_count++;
    return true;
}

/* "click:400,300:90" */
static void read_click(char *tok) {
    float x = 0, y = 0;
    long  at = -1;
    if (sscanf(tok + 6, "%f,%f:%ld", &x, &y, &at) != 3 || at < 0 || x < 0 || y < 0) {
        note("click entry ignored (form: click:x,y:frame)", tok);
        return;
    }
    if (!add_input(true, SDL_SCANCODE_UNKNOWN, SDL_KMOD_NONE, x, y, at, at)) {
        note("input plan full, entry ignored", tok);
        return;
    }
    add_shot(at + 2);
}

/* "type:help:200": one tap per letter, two frames apart. */
static void read_word(char *tok) {
    SDL_Scancode (*code_from_key)(SDL_Keycode, SDL_Keymod *) = real("SDL_GetScancodeFromKey");
    char *word  = tok + 5;
    char *colon = strrchr(word, ':');
    long  at    = -1;
    if (colon == NULL || colon == word || sscanf(colon + 1, "%ld", &at) != 1 || at < 0) {
        note("type entry ignored (form: type:word:frame)", tok);
        return;
    }
    *colon = '\0';
    long f = at;
    for (const char *c = word; *c != '\0'; c++, f += 2) {
        SDL_Keymod   mod  = SDL_KMOD_NONE;
        SDL_Scancode code = code_from_key((SDL_Keycode)(unsigned char)*c, &mod);
        if (code <= SDL_SCANCODE_UNKNOWN || code >= SDL_SCANCODE_COUNT) {
            char one[2] = {*c, '\0'};
            note("cannot type this character", one);
            continue;
        }
        if (!add_input(false, code, mod, 0, 0, f, f)) {
            note("input plan full, rest of word ignored", word);
            return;
        }
    }
    add_shot(f);
}

/* "R:500" or "W:10-120" */
static void read_key(char *tok) {
    SDL_Scancode (*code_from_name)(const char *) = real("SDL_GetScancodeFromName");
    char *colon = strrchr(tok, ':');
    if (colon == NULL) {
        note("key plan entry ignored", tok);
        return;
    }
    *colon = '\0';
    long from = 0, to = 0;
    int  n    = sscanf(colon + 1, "%ld-%ld", &from, &to);
    if (n < 1 || from < 0) {
        note("key plan entry ignored", tok);
        return;
    }
    if (n == 1) {
        to = from + 1; /* a tap: down for two frames */
    }
    SDL_Scancode code = code_from_name(tok);
    if (code <= SDL_SCANCODE_UNKNOWN || code >= SDL_SCANCODE_COUNT) {
        note("unknown key name", tok);
        return;
    }
    if (!add_input(false, code, SDL_KMOD_NONE, 0, 0, from, to)) {
        note("input plan full, entry ignored", tok);
        return;
    }
    add_shot(from + 2);
}

static void read_plan(const char *text) {
    char copy[4096];
    snprintf(copy, sizeof(copy), "%s", text);
    for (char *tok = strtok(copy, " \n\t"); tok != NULL; tok = strtok(NULL, " \n\t")) {
        if (strncmp(tok, "click:", 6) == 0) {
            read_click(tok);
        } else if (strncmp(tok, "type:", 5) == 0) {
            read_word(tok);
        } else {
            /* Older plans separate keys with commas: "W:10-120,R:500". */
            char *save = NULL;
            for (char *k = strtok_r(tok, ",", &save); k != NULL; k = strtok_r(NULL, ",", &save)) {
                read_key(k);
            }
        }
    }
}

static void setup(void) {
    if (ready) {
        return;
    }
    ready = true;

    const char *v = getenv("PLAY_OUT");
    if (v != NULL && v[0] != '\0') {
        snprintf(out_dir, sizeof(out_dir), "%s", v);
    }
    v = getenv("PLAY_FRAMES");
    if (v != NULL && atol(v) > 0) {
        max_frames = atol(v);
    }
    v = getenv("PLAY_FPS");
    if (v != NULL && atol(v) > 0) {
        fps = atol(v);
    }

    char path[600];
    snprintf(path, sizeof(path), "%s/trace.tsv", out_dir);
    trace = fopen(path, "w");
    if (trace == NULL) {
        fprintf(stderr, "sdl-probe: cannot write %s\n", path);
        _exit(98);
    }
    atexit(game_ended);

    v = getenv("PLAY_SHOTS");
    if (v != NULL) {
        char copy[256];
        snprintf(copy, sizeof(copy), "%s", v);
        for (char *tok = strtok(copy, " ,"); tok != NULL; tok = strtok(NULL, " ,")) {
            add_shot(atol(tok));
        }
    }
    v = getenv("PLAY_KEYS");
    if (v != NULL) {
        read_plan(v);
    }
}

/* Press and release keys and mouse buttons for the frame that is about to
 * start. */
static void apply_inputs(SDL_Renderer *renderer) {
    static bool (*push)(SDL_Event *);
    static SDL_Keycode (*key_from_code)(SDL_Scancode, SDL_Keymod, bool);
    static SDL_WindowID window_id;
    for (int i = 0; i < plan_count; i++) {
        bool down = (frame >= plan[i].from && frame <= plan[i].to);
        if (plan[i].click ? (down == plan[i].down) : (down == keys[plan[i].code])) {
            continue;
        }
        if (push == NULL) {
            SDL_Window *(*get_window)(SDL_Renderer *) = real("SDL_GetRenderWindow");
            SDL_WindowID (*get_id)(SDL_Window *)      = real("SDL_GetWindowID");
            push          = real("SDL_PushEvent");
            key_from_code = real("SDL_GetKeyFromScancode");
            SDL_Window *w = get_window(renderer);
            window_id     = (w != NULL) ? get_id(w) : 0;
        }
        SDL_Event ev;
        if (plan[i].click) {
            plan[i].down = down;
            if (down) {
                mouse_x = plan[i].x;
                mouse_y = plan[i].y;
                memset(&ev, 0, sizeof(ev));
                ev.type            = SDL_EVENT_MOUSE_MOTION;
                ev.motion.timestamp = clock_ns;
                ev.motion.windowID = window_id;
                ev.motion.x        = mouse_x;
                ev.motion.y        = mouse_y;
                (void)push(&ev);
            }
            mouse_down = down;
            memset(&ev, 0, sizeof(ev));
            ev.type             = down ? SDL_EVENT_MOUSE_BUTTON_DOWN : SDL_EVENT_MOUSE_BUTTON_UP;
            ev.button.timestamp = clock_ns;
            ev.button.windowID  = window_id;
            ev.button.button    = SDL_BUTTON_LEFT;
            ev.button.down      = down;
            ev.button.clicks    = 1;
            ev.button.x         = plan[i].x;
            ev.button.y         = plan[i].y;
            (void)push(&ev);
            continue;
        }
        SDL_Scancode code = plan[i].code;
        keys[code]        = down;
        memset(&ev, 0, sizeof(ev));
        ev.type          = down ? SDL_EVENT_KEY_DOWN : SDL_EVENT_KEY_UP;
        ev.key.timestamp = clock_ns;
        ev.key.windowID  = window_id;
        ev.key.scancode  = code;
        ev.key.key       = key_from_code(code, plan[i].mod, false);
        ev.key.mod       = plan[i].mod;
        ev.key.down      = down;
        (void)push(&ev);
    }
}

static void record(char kind, float x, float y, float w, float h, const char *text) {
    setup();
    fprintf(trace, "%c\t%ld\t%.2f\t%.2f\t%.2f\t%.2f", kind, frame,
            x * scale_x, y * scale_y, w * scale_x, h * scale_y);
    if (text != NULL) {
        fputc('\t', trace);
        for (const char *c = text; *c != '\0'; c++) {
            fputc((*c == '\t' || *c == '\n' || *c == '\r') ? ' ' : *c, trace);
        }
    }
    fputc('\n', trace);
}

static void save_picture(SDL_Renderer *renderer) {
    SDL_Surface *(*read_pixels)(SDL_Renderer *, const SDL_Rect *) = real("SDL_RenderReadPixels");
    void (*destroy)(SDL_Surface *)                                = real("SDL_DestroySurface");
    const char *(*get_error)(void)                                = real("SDL_GetError");
    bool (*save)(SDL_Surface *, const char *) = dlsym(RTLD_NEXT, "SDL_SavePNG");
    const char *ext = "png";
    if (save == NULL) { /* SDL older than 3.4 */
        save = real("SDL_SaveBMP");
        ext  = "bmp";
    }
    SDL_Surface *s = read_pixels(renderer, NULL);
    if (s == NULL) {
        note("no picture", get_error());
        return;
    }
    char path[600];
    snprintf(path, sizeof(path), "%s/frame-%05ld.%s", out_dir, frame, ext);
    if (!save(s, path)) {
        note("no picture", get_error());
    }
    destroy(s);
}

/* ---- drawing ---------------------------------------------------------- */

bool SDL_RenderFillRect(SDL_Renderer *renderer, const SDL_FRect *rect) {
    static bool (*fn)(SDL_Renderer *, const SDL_FRect *);
    if (fn == NULL) fn = real("SDL_RenderFillRect");
    if (rect != NULL) record('R', rect->x, rect->y, rect->w, rect->h, NULL);
    return fn(renderer, rect);
}

bool SDL_RenderFillRects(SDL_Renderer *renderer, const SDL_FRect *rects, int count) {
    static bool (*fn)(SDL_Renderer *, const SDL_FRect *, int);
    if (fn == NULL) fn = real("SDL_RenderFillRects");
    for (int i = 0; rects != NULL && i < count; i++) {
        record('R', rects[i].x, rects[i].y, rects[i].w, rects[i].h, NULL);
    }
    return fn(renderer, rects, count);
}

bool SDL_RenderRect(SDL_Renderer *renderer, const SDL_FRect *rect) {
    static bool (*fn)(SDL_Renderer *, const SDL_FRect *);
    if (fn == NULL) fn = real("SDL_RenderRect");
    if (rect != NULL) record('R', rect->x, rect->y, rect->w, rect->h, NULL);
    return fn(renderer, rect);
}

bool SDL_RenderRects(SDL_Renderer *renderer, const SDL_FRect *rects, int count) {
    static bool (*fn)(SDL_Renderer *, const SDL_FRect *, int);
    if (fn == NULL) fn = real("SDL_RenderRects");
    for (int i = 0; rects != NULL && i < count; i++) {
        record('R', rects[i].x, rects[i].y, rects[i].w, rects[i].h, NULL);
    }
    return fn(renderer, rects, count);
}

bool SDL_RenderTexture(SDL_Renderer *renderer, SDL_Texture *texture,
                       const SDL_FRect *srcrect, const SDL_FRect *dstrect) {
    static bool (*fn)(SDL_Renderer *, SDL_Texture *, const SDL_FRect *, const SDL_FRect *);
    if (fn == NULL) fn = real("SDL_RenderTexture");
    if (dstrect != NULL) record('T', dstrect->x, dstrect->y, dstrect->w, dstrect->h, NULL);
    return fn(renderer, texture, srcrect, dstrect);
}

bool SDL_RenderDebugText(SDL_Renderer *renderer, float x, float y, const char *str) {
    static bool (*fn)(SDL_Renderer *, float, float, const char *);
    if (fn == NULL) fn = real("SDL_RenderDebugText");
    if (str != NULL) {
        record('X', x, y, (float)(SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE * strlen(str)),
               (float)SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE, str);
    }
    return fn(renderer, x, y, str);
}

bool SDL_RenderDebugTextFormat(SDL_Renderer *renderer, float x, float y, const char *fmt, ...) {
    char buf[1024];
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    return SDL_RenderDebugText(renderer, x, y, buf);
}

bool SDL_SetRenderScale(SDL_Renderer *renderer, float scaleX, float scaleY) {
    static bool (*fn)(SDL_Renderer *, float, float);
    if (fn == NULL) fn = real("SDL_SetRenderScale");
    scale_x = scaleX;
    scale_y = scaleY;
    return fn(renderer, scaleX, scaleY);
}

bool SDL_RenderPresent(SDL_Renderer *renderer) {
    static bool (*fn)(SDL_Renderer *);
    if (fn == NULL) fn = real("SDL_RenderPresent");
    setup();
    if (!size_written) {
        bool (*out_size)(SDL_Renderer *, int *, int *) = real("SDL_GetRenderOutputSize");
        int w = 0, h = 0;
        if (out_size(renderer, &w, &h)) {
            fprintf(trace, "W\t%d\t%d\n", w, h);
        }
        size_written = true;
    }
    for (int i = 0; i < shot_count; i++) {
        if (shots[i] == frame) {
            save_picture(renderer);
            break; /* two plan entries can ask for the same frame */
        }
    }
    bool ok = fn(renderer);
    fprintf(trace, "P\t%ld\n", frame);
    fflush(trace); /* so a crash in the next frame does not lose this one */
    frame++;
    clock_ns += 1000000000ULL / (Uint64)fps;
    if (frame >= max_frames) {
        fprintf(trace, "END\t%ld\tlimit\n", frame);
        fclose(trace);
        trace = NULL;
        _exit(0);
    }
    apply_inputs(renderer);
    return ok;
}

/* ---- the clock: game time, not real time ------------------------------ */

/* Each read moves the clock on by a millionth of a second, so a game that
 * waits in a loop for time to pass does not wait forever. */
static Uint64 now_ns(void) {
    setup();
    clock_ns += 1000;
    return clock_ns;
}

Uint64 SDL_GetPerformanceCounter(void)   { return now_ns(); }
Uint64 SDL_GetPerformanceFrequency(void) { return 1000000000ULL; }
Uint64 SDL_GetTicksNS(void)              { return now_ns(); }
Uint64 SDL_GetTicks(void)                { return now_ns() / 1000000ULL; }
void   SDL_Delay(Uint32 ms)              { (void)ms; }
void   SDL_DelayNS(Uint64 ns)            { (void)ns; }
void   SDL_DelayPrecise(Uint64 ns)       { (void)ns; }

/* ---- the keyboard and mouse: from the plan, not from a person ---------- */

const bool *SDL_GetKeyboardState(int *numkeys) {
    setup();
    if (numkeys != NULL) {
        *numkeys = SDL_SCANCODE_COUNT;
    }
    return keys;
}

SDL_MouseButtonFlags SDL_GetMouseState(float *x, float *y) {
    setup();
    if (x != NULL) {
        *x = mouse_x;
    }
    if (y != NULL) {
        *y = mouse_y;
    }
    return mouse_down ? SDL_BUTTON_LMASK : 0;
}
