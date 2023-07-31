(use testament)


(import ../argy-bargy)


(deftest parse-with-option-flag
  (def config {:rules ["--foo" {:kind :flag}]})
  (def actual
    (with-dyns [:args @["program" "--foo"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    {:cmd "program" :opts @{"foo" true} :params @{} :out @"" :err @""})
  (is (== expect actual)))


(deftest parse-with-option-count
  (def config {:rules ["--foo" {:kind :count}]})
  (def actual
    (with-dyns [:args @["program" "--foo" "--foo"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    {:cmd "program" :opts @{"foo" 2} :params @{} :out @"" :err @""})
  (is (== expect actual)))


(deftest parse-with-option-single
  (def config {:rules ["--foo" {:kind :single}]})
  (def actual
    (with-dyns [:args @["program" "--foo" "bar"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    {:cmd "program" :opts @{"foo" "bar"} :params @{} :out @"" :err @""})
  (is (== expect actual)))


(deftest parse-with-option-multi
  (def config {:rules ["--foo" {:kind :multi}]})
  (def actual
    (with-dyns [:args @["program" "--foo" "bar" "--foo" "qux"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    {:cmd "program" :opts @{"foo" ["bar" "qux"]} :params @{}
     :out @"" :err @""})
  (is (== expect actual)))


(deftest parse-with-option-avoid
  (def config {:rules [:foo {}]})
  (def actual
    (with-dyns [:args @["program" "--" "-foo"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    {:cmd "program" :opts @{} :params @{:foo "-foo"} :out @"" :err @""})
  (is (== expect actual)))


(deftest parse-with-param-number
  (def config {:rules [:foo {:help "A parameter"
                             :value :integer}]})
  (def actual
    (with-dyns [:args @["program" "1"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    {:cmd "program" :opts @{} :params @{:foo 1} :out @"" :err @""})
  (is (== expect actual)))


(deftest parse-with-param-capture
  (def config {:rules [:foo {:value :integer}
                       :bar {:rest? true
                             :value :integer}
                       :qux {:value :integer}]})
  (def actual
    (with-dyns [:args @["program" "1" "2" "3" "4" "5"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    {:cmd "program" :opts @{} :params @{:foo 1 :bar [2 3 4] :qux 5}
     :out @"" :err @""})
  (is (== expect actual)))


(deftest parse-with-param-req
  (def config {:rules [:foo {:req? true}]})
  (def actual
    (with-dyns [:args @["program"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    @{:cmd "program" :error? true :opts @{} :params @{} :out @""
      :err "program: foo is required\nTry 'program --help' for more information.\n"})
  (is (== expect actual)))


(deftest parse-subcommand-with-option-flag
  (def config {:subs ["example" {:rules ["--foo" {:kind :flag}]}]})
  (def actual
    (with-dyns [:args @["program" "example" "--foo"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    @{:cmd "program" :opts @{} :sub @{:cmd "example" :opts @{"foo" true} :params @{}}
      :out @"" :err @""})
  (is (== expect actual)))


(deftest parse-multiple-subcommands
  (def config {:subs ["foo" {:subs ["bar" {}]}]})
  (def actual
    (with-dyns [:args @["program" "foo" "bar"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    @{:cmd "program" :opts @{}
      :sub {:cmd "foo" :opts @{} :sub @{:cmd "bar" :opts @{} :params @{}}}
      :out @"" :err @""})
  (is (== expect actual)))


(deftest parse-with-usage-error
  (def msg
      `program: unrecognized option '--foo'
      Try 'program --help' for more information.`)
  (def config {})
  (def actual
    (with-dyns [:args @["program" "--foo"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
     {:cmd "program" :error? true :opts @{} :params @{}
      :out @"" :err (buffer msg "\n")})
  (is (== expect actual)))


(deftest parse-with-usage-help
  (def msg
      `usage: program

      Options:

       -h, --help    Show this help message.`)
  (def config {})
  (def actual
    (with-dyns [:args @["program" "--help"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    {:cmd "program" :help? true :opts @{} :params @{}
     :out (buffer msg "\n") :err @""})
  (is (== expect actual)))


(deftest parse-with-usage-help-separators
  (def msg
       `usage: program [--foo]

       Options:

            --foo     An option.

        -h, --help    Show this help message.`)
  (def config {:rules ["--foo" {:kind :flag
                                :help "An option."}
                       "---"]})
  (def actual
    (with-dyns [:args @["program" "--help"]]
      (argy-bargy/parse-args "program" config)))
  (def expect
    @{:cmd "program" :help? true :opts @{} :params @{}
      :out (buffer msg "\n") :err @""})
  (is (== expect actual)))


(run-tests!)
