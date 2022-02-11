;;; tmcalculator.el --- Use NEB's Tm calculator to predict PCR annealing temperature
;;; Commentary:
;;; Tired of leaving Emacs to calculate PCR settings?!

;;; Code:
(require 'request)
(require 'cl)

(defcustom tmcalculator/email "your.email@here"
  "User email ID. Required by NEB." )

(defun get-annealing-temperature ()
  "Prompt users for two primers, and get anneal temp."
  (interactive)
  (let ((p1 (read-string "Input P1: "))
        (p2 (read-string "Input P2: "))
        (reagent (completing-read "PCR kit: " '("onetaq_std" "onetaq_gc" "taq" "phusion" "q5" "vent" "lataq" "hktaq")))
        (conc (read-number "Concentration of primer (in mM): " 200)))
    (setq nebstr (format "https://tmapi.neb.com/tm/%s/%s/%s/%s?%s&fmtf=short"
          reagent conc p1 p2 tmcalculator/email))
    (message "%s" nebstr)
    (request nebstr
      :type "GET"
      :parser 'json-read
      :success (cl-function
                (lambda (&key data &allow-other-keys)
                  (let ((dat (assoc 'data data)))
                    (message "Seq1 [Tm=%s]\nSeq2 [Tm=%s]\nAnnealing Temp: %s"
                             (cdr (assoc 'tm1min dat))
                             (cdr (assoc 'tm2min dat))
                             (cdr (assoc 'ta dat)))
                    (kill-new (format "%s" (cdr (assoc 'ta dat))))
                    ))))))
(provide 'tmcalculator)
;;; tmcalculator.el ends here
