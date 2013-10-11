;;; autoexp-mode.el --- a major-mode for msvc's autoexp.dat file
;;
;; Copyright 2013 Florian Kaufmann <sensorflo@gmail.com>
;;
;; Author: Florian Kaufmann <sensorflo@gmail.com>
;; Created: 2013
;; Keywords: languages
;; 
;; This file is not part of GNU Emacs.
;; 
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;; 
;;; Commentary:
;; 
;; A major-mode for msvc's autoexp.dat file.
;; 
;; Micorosoft itself does not document it's own autoexp.dat, apart from a few
;; hints in the commentary section at the beginning of autoexp.dat. Rather
;; rudimentary 3rd party documentation is available here:
;; - https://svn.boost.org/trac/boost/wiki/DebuggerVisualizers
;; - http://www.virtualdub.org/blog/pivot/entry.php?id=120


;;; Variables:
(defvar autoexp-mode-hook nil
  "Normal hook run when entering autoexp mode.")

(defconst autoexp-re-autoexp-type
  "\\(?:\\([^ \t\n=]\\|[^ \t\n=].*?[^ \t\n=]\\)[ \t]*=\\)")

(defconst autoexp-re-visualizer-type
  "\\(?:[ \t]*\\(.+?\\)[ \t]*{\\)")

(defconst autoexp-re-outline-level1
  (concat "\\(?:" autoexp-re-visualizer-type "\\|" autoexp-re-autoexp-type "\\)"))

(defconst autoexp-re-outline-level2
  "\\b[ \t]*\\(?:preview\\|children\\|stringview\\)\\b")

(defconst autoexp-font-lock-keywords
  (list
   ;; genral
   ;; ------
   ;; section
   (cons "^\\[.*?\\]" 'font-lock-variable-name-face)
   ;; integers dec/oct
   (cons "\\b[0-9]+[UuLl]*\\b" 'font-lock-constant-face)
   ;; integers hex
   (cons "\\b0[xX][0-9a-fA-F]*\\b" 'font-lock-constant-face)
   ;; floating point
   (cons "\\(?:\\b[0-9]+\\)?\\.?\\b[0-9]+\\(?:[eE][-+]?[0-9]+\\)?[LlfF]\\b" 'font-lock-constant-face)
   ;; 
   (cons "\\$\\(ADDIN\\|BUILTIN\\)" 'font-lock-keyword-face)
   ;; todo: formatspecifier !!!!!!!!!!!!!!!!!!!!

   ;; for AutoExpand section
   ;; ----------------------
   (list (concat "^" autoexp-re-autoexp-type)
         (list 1 'font-lock-function-name-face))
   (list "\\(?:[=>]\\|\\=\\)[ \t]*\\([^ \t\n<>=]\\|[^ \t\n<>=].*?[^ \t\n<>=]\\)[ \t]*=<.*?>" (list 1 'font-lock-constant-face))

   ;; for Visualizer section
   ;; ----------------------
   ;; definition of a visualizer rule for given set of types
   (list (concat "^" autoexp-re-visualizer-type)
         (list 1 'font-lock-function-name-face))
   ;; 
   (list "\\b\\(preview\\|stringview\\|children\\)[ \n\t]*(" (list 1 'font-lock-variable-name-face))
   ;; string concatenation
   (list "\\(#\\)(" (list 1 'font-lock-keyword-face))
   ;;
   (cons "#\\(?:if\\|elif\\|else\\|switch\\|case\\|default\\|except\\|array\\|list\\|tree\\)\\b" 'font-lock-keyword-face)
   ;;
   (cons "\\b\\(?:expr\\|size\\|rank\\|base\\|next\\|head\\|skip\\|left\\|right\\):" 'font-lock-builtin-face)
   ;; ??? what construct is that ???? I see it in the autoexp.dat all the time,
   ;; but I don't properly understand it !!!!!!!!!!!!!!!!!!!!!
   (list "#([ \t\n]*\\([^ \t\n#(:]\\|[^ \t\n#(:].*?[^ \t\n#(:]\\)[ \n\t]*:" (list 1 'font-lock-constant-face))
   ))


;;; Code:
(defun autoexp-outline-level ()
  "autoexp-mode's function for `outline-level'."
  (cond
   ((looking-at autoexp-re-outline-level1) 1)
   ((looking-at autoexp-re-outline-level2) 2)
   (t 3)))


;;;###autoload
(define-derived-mode autoexp-mode text-mode "autoexp"
  "Major mode for editing msvc's autoexp.dat files.
Turning on autoexp mode runs the normal hook `autoexp-mode-hook'."
  
  ;; syntax table
  (modify-syntax-entry ?$ ".")
  (modify-syntax-entry ?% ".")
  (modify-syntax-entry ?& ".")
  (modify-syntax-entry ?' ".")
  (modify-syntax-entry ?` ".")
  (modify-syntax-entry ?* ".")
  (modify-syntax-entry ?+ ".")
  (modify-syntax-entry ?. ".")
  (modify-syntax-entry ?/ ".")
  (modify-syntax-entry ?< ".")
  (modify-syntax-entry ?= ".")
  (modify-syntax-entry ?> ".")
  (modify-syntax-entry ?\\ ".")
  (modify-syntax-entry ?| ".")
  (modify-syntax-entry ?_ ".")
  (modify-syntax-entry ?# ".")
  (modify-syntax-entry ?\" "\"")
  (modify-syntax-entry ?\; "<")
  (modify-syntax-entry ?\n ">")
  (modify-syntax-entry ?\r ">")

  ;; comments
  (set (make-local-variable 'comment-column) 0)
  (set (make-local-variable 'comment-start) ";")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-start-skip) "\\(;[ \t]*\\)")
  (set (make-local-variable 'comment-end-skip) "[ \t]*\\(?:\n\\|\\'\\)")
  
  ;; font lock
  (set (make-local-variable 'font-lock-defaults)
       '(autoexp-font-lock-keywords))
  
  ;; outline mode
  (set (make-local-variable outline-heading-alist)
       '((autoexp-re-outline-level1 . 1)
         (autoexp-re-outline-level2 . 2)))
  
  (run-hooks 'autoexp-mode-hook))


(provide 'autoexp-mode)

;;; autoexp-mode.el ends here
