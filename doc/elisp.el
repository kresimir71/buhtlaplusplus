
;; emacs keyboard macro to produce markdown files
(defun README-org-to-README-md ()
 (interactive)
 (setq buf02 (current-buffer))
 (goto-line 1)
 (replace-regexp "[/][*]C" "")
 (goto-line 1)
 (replace-regexp "C[*][/]" "") 
 (org-md-export-to-markdown)
 (switch-to-buffer buf02)
 (kk-revert-buffer-force) 
)
