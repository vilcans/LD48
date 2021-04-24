sprite_height = 16

; Sprite is always 2 bytes wide, so it will be drawn as 2 or 3 bytes
; depending on the horizontal position.
; If the visual sprite is thinner than 16 pixels, this can be used to draw
; 2 bytes wide even when x & 7 != 0.
sprite_visible_width = 16
