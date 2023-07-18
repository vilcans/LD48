    EXTERN intro_text
    EXTERN instructions_text
    EXTERN pickup_text
    EXTERN completed_text
    EXTERN press_key_text

    SECTION lowmem

intro_text:
    ;  '------------------------------------'
    db 9,'CROWN OF THE MOUNTAIN KING',0
    db 6,'v'
    INCBIN "version.txt"
    db 0
    db 7
    db 127," Martin Vilcans 2023",0
    db 0
    db "Rumor has it that the long lost",0
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
    db $ff

instructions_text:
    ;  '------------------------------------'
    db 9,'INSTRUCTIONS',0
    db 7
    db 0
    db "Apply thrust to accelerate upwards.",0
    db "Gravity pulls you down.",0
    db "Steer freely left and right.",0
    db 0
    db "Be careful when accelerating so you",0
    db "don't crash into something above.",0
    db 0
    db "Apply a little thrust now and then",0
    db "while falling so you have time to",0
    db "react.",0
    db 0
    db "Do not touch anything except the",0
    db "white landing pads. If you touch",0
    db "down gently on one of those, your",0
    db "fuel will be refilled, and you will",0
    db "start on that pad if you crash.",0
    db 0
    db 8,"Keyboard controls:",0
    db 6,"A = left, D = right, W = thrust",0
    db $ff

pickup_text:
    db 9,"YOU FOUND THE CROWN!",0
    db 0
    db 7,"But it is very heavy!",0
    db 0
    db "Can you bring it back to",0
    db "the surface?",0
    db $ff

completed_text:
    db 9,"SUCCESS!",0
    db 0
    db 7,"You brought the crown",0
    db "back to the surface!",0
    db 0
    db "You are a very skilled",0
    db "hovercraft pilot.",0
    db $ff

press_key_text:
    db 7,"Press ENTER to continue",0
    db $ff
