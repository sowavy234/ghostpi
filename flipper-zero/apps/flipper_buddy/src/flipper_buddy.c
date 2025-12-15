/*
 * Flipper Buddy - AI-Powered Companion for Flipper Zero
 * GhostPi / Wavy's World
 * 
 * EDUCATIONAL PURPOSES ONLY
 * 
 * This app provides an AI-powered interface for Flipper Zero
 * with integration to GhostPi pentesting tools.
 */

#include <furi.h>
#include <furi_hal.h>
#include <gui/gui.h>
#include <input/input.h>
#include <notification/notification_messages.h>
#include <storage/storage.h>
#include <dialogs/dialogs.h>

#define TAG "FlipperBuddy"

typedef struct {
    Gui* gui;
    ViewPort* view_port;
    FuriMessageQueue* event_queue;
    NotificationApp* notification;
    
    // App state
    uint8_t selected_menu;
    uint8_t menu_items;
    bool connected_to_ghostpi;
} FlipperBuddyApp;

typedef enum {
    MenuMain,
    MenuPentest,
    MenuBruteForce,
    MenuMarauder,
    MenuAIHelper,
    MenuSettings
} MenuType;

static void draw_callback(Canvas* canvas, void* ctx) {
    FlipperBuddyApp* app = (FlipperBuddyApp*)ctx;
    
    canvas_clear(canvas);
    canvas_set_font(canvas, FontPrimary);
    
    // Draw header
    canvas_draw_str(canvas, 0, 10, "Flipper Buddy");
    canvas_draw_str(canvas, 0, 20, "GhostPi Companion");
    
    // Draw menu
    switch(app->selected_menu) {
        case MenuMain:
            canvas_draw_str(canvas, 0, 35, "> Pentesting Tools");
            canvas_draw_str(canvas, 0, 45, "  Brute Force");
            canvas_draw_str(canvas, 0, 55, "  Marauder WiFi");
            canvas_draw_str(canvas, 0, 65, "  AI Helper");
            break;
        case MenuPentest:
            canvas_draw_str(canvas, 0, 35, "Pentesting Tools:");
            canvas_draw_str(canvas, 0, 45, "- WiFi Attacks");
            canvas_draw_str(canvas, 0, 55, "- RFID/NFC");
            canvas_draw_str(canvas, 0, 65, "- BadUSB");
            break;
        case MenuBruteForce:
            canvas_draw_str(canvas, 0, 35, "Brute Force:");
            canvas_draw_str(canvas, 0, 45, "- WiFi (WPA/WPA2)");
            canvas_draw_str(canvas, 0, 55, "- SSH/FTP");
            canvas_draw_str(canvas, 0, 65, "- PIN Cracking");
            break;
        case MenuMarauder:
            canvas_draw_str(canvas, 0, 35, "Marauder WiFi:");
            canvas_draw_str(canvas, 0, 45, "- Beacon Spam");
            canvas_draw_str(canvas, 0, 55, "- Deauth Attack");
            canvas_draw_str(canvas, 0, 65, "- Handshake Capture");
            break;
        case MenuAIHelper:
            canvas_draw_str(canvas, 0, 35, "AI Helper:");
            canvas_draw_str(canvas, 0, 45, "- Code Generation");
            canvas_draw_str(canvas, 0, 55, "- Attack Planning");
            canvas_draw_str(canvas, 0, 65, "- Tool Suggestions");
            break;
    }
    
    // Draw footer
    canvas_set_font(canvas, FontSecondary);
    canvas_draw_str(canvas, 0, 120, "EDUCATIONAL ONLY");
    
    if(app->connected_to_ghostpi) {
        canvas_draw_str(canvas, 80, 120, "GhostPi: ON");
    }
}

static void input_callback(InputEvent* input_event, void* ctx) {
    FlipperBuddyApp* app = (FlipperBuddyApp*)ctx;
    furi_message_queue_put(app->event_queue, input_event, FuriWaitForever);
}

static FlipperBuddyApp* flipper_buddy_alloc() {
    FlipperBuddyApp* app = malloc(sizeof(FlipperBuddyApp));
    
    app->gui = furi_record_open(RECORD_GUI);
    app->notification = furi_record_open(RECORD_NOTIFICATION);
    
    app->view_port = view_port_alloc();
    view_port_draw_callback_set(app->view_port, draw_callback, app);
    view_port_input_callback_set(app->view_port, input_callback, app);
    
    gui_add_view_port(app->gui, app->view_port, GuiLayerFullscreen);
    
    app->event_queue = furi_message_queue_alloc(8, sizeof(InputEvent));
    
    app->selected_menu = MenuMain;
    app->menu_items = 5;
    app->connected_to_ghostpi = false;
    
    // Check for GhostPi connection
    // This would check for USB/network connection to GhostPi
    // For now, we'll assume it's available
    
    return app;
}

static void flipper_buddy_free(FlipperBuddyApp* app) {
    view_port_enabled_set(app->view_port, false);
    gui_remove_view_port(app->gui, app->view_port);
    view_port_free(app->view_port);
    
    furi_message_queue_free(app->event_queue);
    
    furi_record_close(RECORD_GUI);
    furi_record_close(RECORD_NOTIFICATION);
    
    free(app);
}

int32_t flipper_buddy_main(void* p) {
    UNUSED(p);
    
    FlipperBuddyApp* app = flipper_buddy_alloc();
    
    // Show notification
    notification_message(app->notification, &sequence_display_backlight_on);
    
    InputEvent event;
    bool running = true;
    
    FURI_LOG_I(TAG, "Flipper Buddy started");
    
    while(running) {
        if(furi_message_queue_get(app->event_queue, &event, FuriWaitForever) == FuriStatusOk) {
            if(event.type == InputTypePress) {
                switch(event.key) {
                    case InputKeyUp:
                        if(app->selected_menu > 0) {
                            app->selected_menu--;
                        }
                        break;
                    case InputKeyDown:
                        if(app->selected_menu < app->menu_items - 1) {
                            app->selected_menu++;
                        }
                        break;
                    case InputKeyOk:
                        // Execute selected action
                        notification_message(app->notification, &sequence_single_vibro);
                        break;
                    case InputKeyBack:
                        running = false;
                        break;
                }
            }
            
            view_port_update(app->view_port);
        }
    }
    
    flipper_buddy_free(app);
    
    return 0;
}

