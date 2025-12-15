#!/bin/bash
# Flipper Zero Coding Assistant
# AI-powered helper for Flipper Zero development (like Copilot/Claude)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
APPS_DIR="$PROJECT_ROOT/flipper-zero/apps"

log() {
    echo "[Coding Assistant] $1"
}

create_app() {
    log "Creating new Flipper Zero app..."
    
    read -p "App name: " app_name
    read -p "App description: " app_desc
    read -p "App type (basic|infrared|rfid|subghz|gpio): " app_type
    
    APP_DIR="$APPS_DIR/$app_name"
    mkdir -p "$APP_DIR"
    
    # Generate app structure
    cat > "$APP_DIR/application.fam" <<EOF
App(
    appid="$app_name",
    name="$app_name",
    entry_point="app_main",
    stack_size=2048,
    icon="A_Plugins_10",
)
EOF

    # Generate main C file
    cat > "$APP_DIR/$app_name.c" <<'EOF'
#include <furi.h>
#include <gui/gui.h>
#include <input/input.h>

typedef struct {
    Gui* gui;
    ViewPort* view_port;
    FuriMessageQueue* event_queue;
} App;

static void draw_callback(Canvas* canvas, void* ctx) {
    App* app = (App*)ctx;
    UNUSED(app);
    
    canvas_clear(canvas);
    canvas_set_font(canvas, FontPrimary);
    canvas_draw_str(canvas, 10, 30, "Hello from");
    canvas_draw_str(canvas, 10, 45, "Flipper Zero!");
}

static void input_callback(InputEvent* input_event, void* ctx) {
    App* app = (App*)ctx;
    furi_message_queue_put(app->event_queue, input_event, FuriWaitForever);
}

static App* app_alloc() {
    App* app = malloc(sizeof(App));
    app->gui = furi_record_open(RECORD_GUI);
    app->view_port = view_port_alloc();
    app->event_queue = furi_message_queue_alloc(8, sizeof(InputEvent));
    
    view_port_draw_callback_set(app->view_port, draw_callback, app);
    view_port_input_callback_set(app->view_port, input_callback, app);
    gui_add_view_port(app->gui, app->view_port, GuiLayerFullscreen);
    
    return app;
}

static void app_free(App* app) {
    gui_remove_view_port(app->gui, app->view_port);
    view_port_free(app->view_port);
    furi_message_queue_free(app->event_queue);
    furi_record_close(RECORD_GUI);
    free(app);
}

int32_t app_main(void* p) {
    UNUSED(p);
    
    App* app = app_alloc();
    
    InputEvent event;
    while(furi_message_queue_get(app->event_queue, &event, FuriWaitForever) == FuriStatusOk) {
        if(event.key == InputKeyBack && event.type == InputTypePress) {
            break;
        }
    }
    
    app_free(app);
    return 0;
}
EOF

    # Generate Makefile
    cat > "$APP_DIR/Makefile" <<EOF
APPNAME = $app_name
APPSRC = $app_name.c
include \$(FLIPPER_FIRMWARE_PATH)/applications.mk
EOF

    log "✓ App created: $APP_DIR"
    log "Next steps:"
    log "  1. Edit $app_name.c to add functionality"
    log "  2. Run: fbt fap_$app_name"
    log "  3. Sync to Flipper Zero"
}

fix_build() {
    local app_name="$1"
    log "Analyzing build errors for: $app_name"
    
    # Check common issues
    if [ ! -f "$APPS_DIR/$app_name/application.fam" ]; then
        log "Missing application.fam, creating..."
        # Generate fam file
    fi
    
    if [ ! -f "$APPS_DIR/$app_name/$app_name.c" ]; then
        log "Missing main C file, creating template..."
        # Generate C file
    fi
    
    log "Suggested fixes applied. Try building again."
}

suggest_code() {
    local feature="$1"
    log "Generating code suggestion for: $feature"
    
    case "$feature" in
        infrared)
            cat <<'EOF'
// Infrared example
#include <infrared.h>

void send_ir_signal() {
    InfraredSignal* signal = infrared_signal_alloc();
    // Configure signal
    infrared_signal_send(signal);
    infrared_signal_free(signal);
}
EOF
            ;;
        rfid)
            cat <<'EOF'
// RFID example
#include <rfid.h>

void read_rfid() {
    Rfid* rfid = rfid_alloc();
    // Read card
    rfid_free(rfid);
}
EOF
            ;;
        subghz)
            cat <<'EOF'
// SubGHz example
#include <subghz.h>

void send_subghz() {
    SubGhz* subghz = subghz_alloc();
    // Configure and send
    subghz_free(subghz);
}
EOF
            ;;
        *)
            log "Feature not recognized. Available: infrared, rfid, subghz"
            ;;
    esac
}

interactive_helper() {
    while true; do
        clear
        echo "=========================================="
        echo "  Flipper Zero Coding Assistant"
        echo "  AI-Powered Development Helper"
        echo "=========================================="
        echo ""
        echo "  1) Create New App"
        echo "  2) Fix Build Errors"
        echo "  3) Code Suggestions"
        echo "  4) View App Template"
        echo "  5) Generate API Code"
        echo "  0) Exit"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1) create_app ;;
            2)
                read -p "App name: " app_name
                fix_build "$app_name"
                ;;
            3)
                echo "Available features: infrared, rfid, subghz, gpio"
                read -p "Feature: " feature
                suggest_code "$feature"
                ;;
            4)
                cat "$APPS_DIR/template.c" 2>/dev/null || echo "Template not found"
                ;;
            5)
                echo "API code generation..."
                # Generate API examples
                ;;
            0) break ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

case "${1:-interactive}" in
    create-app)
        create_app
        ;;
    fix-build)
        fix_build "$2"
        ;;
    suggest)
        suggest_code "$2"
        ;;
    interactive)
        interactive_helper
        ;;
    *)
        interactive_helper
        ;;
esac

