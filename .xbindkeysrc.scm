(define (first-binding)
  (xbindkey '(Mod4 t) "xterm")
  (xbindkey '(Mod4 o) "krunner")
  (xbindkey-function '(Mod4 x) run-app)
  (xbindkey-function '(Mod4 g) run-gajim))

(define (reset-first-binding)
  "reset first binding"
  (ungrab-all-keys)
  (remove-all-keys)
  (first-binding)
  (grab-all-keys))

(define (runc command)
  (run-command command)
  (reset-first-binding))

(define (gajim-contacts)
  (ungrab-all-keys)
  (remove-all-keys)

  (xbindkey-function 'a
                     (lambda ()
                       (runc "gajim-remote open_chat axce1@jabber.ru")))
  (xbindkey-function 'o
                     (lambda ()
                       (runc "gajim-remote open_chat www.fyl@gmail.com")))
  (xbindkey-function 'm
                     (lambda ()
                       (runc "gajim-remote open_chat master_bo@jabber.ru")))
  (xbindkey-function 'j
                     (lambda ()
                       (runc "gajim-remote open_chat juick@juick.com")))

  (grab-all-keys))


(define (run-gajim)
  (ungrab-all-keys)
  (remove-all-keys)
  (xbindkey-function 'r
                     (lambda ()
                       (runc "gajim-remote toggle_roster_appearance")))
  (xbindkey-function 'w gajim-contacts)
  
  (grab-all-keys))
  

(define (run-app)
  (ungrab-all-keys)
  (remove-all-keys)
  (xbindkey-function 'f
                     (lambda ()
                       (runc "firefox")))
  (xbindkey-function 'c
                     (lambda ()
                       (runc "chromium-browser")))
  (xbindkey-function 'g
                     (lambda ()
                       (runc "gajim")))
  (xbindkey-function 'h
                     (lambda ()
                       (runc "xterm -e htop")))
  (xbindkey-function 'e
                     (lambda ()
                       (runc "emacs")))
  (xbindkey-function 'p
                     (lambda ()
                       (runc "pavucontrol")))
  (grab-all-keys))

(first-binding)
