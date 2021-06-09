    EXTERN intro_text

    SECTION lowmem

intro_text:
    ;  '------------------------------------'
    db 9,'CROWN OF THE MOUNTAIN KING',0
    db 5,'v'
    INCBIN "version.txt"
    db 0
    db 0
    db 7,"Rumor has it that the long lost",0
    db "crown of the Mountain King can",0
    db "be found somewhere in the caverns",0
    db "below these abandoned mines.",0
    db 0
    db "Your mission is to find it,",0
    db "and get it safely back to the",0
    db "surface.",0
    db 0
    db "Steer your hovercraft carefully to",0
    db "avoid the obstacles that hide in",0
    db "the dark.",0
    db 0
    db 8,"Keyboard controls:",0
    db 6,"A = left",0
    db "D = right",0
    db "W = thrust",0
    db 0
    db 7,"Press ENTER to continue",0
    db $ff
