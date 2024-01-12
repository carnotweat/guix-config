;;(define-configuration buffer
;;  ((default-modes (append '(emacs-mode) %slot-default%))))

(define-configuration browser
  ((session-restore-prompt :always-restore)
   (autofills (list (make-autofill :key "Current time"
                                   :fill (lambda () (format nil "~a" (local-time:now))))))))



(define-configuration web-buffer
  ((default-modes (append '(emacs-mode blocker-mode) %slot-default%))
   (password-interface (make-instance 'password:password-store-interface))))

(define-configuration buffer
  ((default-modes (append '(emacs-mode) %slot-default%))
   (override-map (let ((map (make-keymap "my-override-map")))
                   (define-key map
                     "M-x" 'execute-command
                     "C-l" 'set-url
                     "C-c l" 'set-url-new-buffer
                     "C-c r" 'reload-current-buffer
                     "C-w" 'noop
                     "C-c p" 'youtube-play-current-page
                     ;;"C-space" 'nyxt/prompt-buffer-mode:toggle-mark
                     ;"M-keypadleft" 'nyxt/web-mode:history-backwards
                     ;"keypadright" 'nyxt/web-mode:history-forwards
                     )
                   map))))

;; Replace reddit.com with old-reddit
(defun old-reddit-handler (request-data)
  (let ((url (url request-data)))
    (setf (url request-data)
          (if (search "reddit.com" (quri:uri-host url))
              (progn
                (setf (quri:uri-host url) "old.reddit.com")
                (log:info "Switching to old Reddit: ~s" (render-url url))
                url)
              url)))
  request-data)

(define-configuration web-buffer
  ((request-resource-hook
    (hooks:add-hook %slot-default% (make-handler-resource #'old-reddit-handler)))))

;; fixing youtube stuff

(define-command youtube-play-current-page ()
  "Watch a Youtube video in the currently open buffer."
    (uiop:run-program
     (list "mpv" (render-url (url(current-buffer))))))

(define-command-global open-in-qutebrowser ()
  "Open the current URL in qutebrowser"
  (uiop:run-program (list "qutebrowser" (render-url (url (current-buffer))))))
