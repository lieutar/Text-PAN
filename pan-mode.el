(require 'outline)

(defun pan-indent-region ())
(defun pan-indent-line ())

(defconst pan-font-lock-keywords
  (append
   outline-font-lock-keywords
   '(("^=.*$"                                0 font-lock-builtin-face)
     ("<\\([^\t\r\n >/]+\\)"                  1 font-lock-function-name-face)
     ("</\\([^\t\r\n >/]+\\)"                 1 font-lock-function-name-face)
     ("<[^>]*\\(/\\)"                         1 font-lock-builtin-face)
     ("<[^>/]*\\(--\\([^\\-]\\|-[^-]\\)*--\\)" 1 fot-lock-comment-face)
     ("<[^>/]*=\\(\"[^\"]*\"\\|'[^']*'\\)"    1 font-lock-string-face)
     ("&[a-zA-Z0-9]+;"                       0 font-lock-variable-name-face)
     ("^ *>| *\\([^\r\n|=]+\\) *|"           1 font-lock-builtin-face)
     ("^ *\\(--+\n\\)"                       1 font-lock-builtin-face)
     )
   ))

    

(defconst pan-mode-syntax-table
  (let ((tbl (make-syntax-table)))
    tbl))

(defvar pan-mode-map
  (let ((km (make-sparse-keymap)))
    (define-key km (kbd "") #'pan)
    km))

(define-derived-mode pan-mode outline-mode "pan"
  "Major mode for editing PAN files.

\\{pan-mode-map}"
;;  (set-syntax-table pan-mode-syntax-table)
  (set (make-local-variable 'indent-line-function) 'pan-indent-line)
  (set (make-local-variable 'indent-region-function) 'pan-indent-region)
  (set (make-local-variable 'forward-sexp-function) 'pan-forward-sexp)
  (setq font-lock-defaults '((pan-font-lock-keywords) nil t)))
