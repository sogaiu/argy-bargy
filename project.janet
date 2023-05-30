(declare-project
  :name "Argy-Bargy"
  :description "A fancy command-line argument parser for Janet"
  :author "Michael Camilleri"
  :license "MIT"
  :url "https://github.com/pyrmont/argy-bargy"
  :repo "git+https://github.com/pyrmont/argy-bargy"
  :dependencies []
  :jeep/tree ".jeep"
  :jeep/dev-dependencies ["https://github.com/pyrmont/testament"])

(declare-source
  :source ["src/argy-bargy.janet"])

(task "dev-deps" []
  (if-let [deps ((dyn :project) :jeep/dev-dependencies)]
    (each dep deps
      (bundle-install dep))
    (do
      (print "no dependencies found")
      (flush))))
