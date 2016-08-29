Scallop
========
A simple command-line arguments parsing library for Scala, written in spirit of Ruby's [Trollop](http://trollop.rubyforge.org/). Cross-built for Scala 2.10, 2.11 and latest 2.12 milestone.

Scallop supports:

* flag, single-value and multiple value options
* POSIX-style short option names (-a) with grouping (-abc)
* GNU-style long option names (--opt, --opt=value)
* unnamed integer options, like GNU tail (-42)
* Property arguments (-Dkey=value, -D key1=value key2=value)
* Non-string types of options and properties values (with extendable converters)
* Powerful matching on trailing args
* Subcommands

For more info and information on usage, you can look into the [project wiki](https://github.com/scallop/scallop/wiki) or consult the [API docs](http://scallop.github.io/scallop/#org.rogach.scallop.package).

Also, I wrote a [blog post](http://blog.rogach.org/2012/04/better-cli-option-parsing-in-scala.html) and [another one](http://blog.rogach.org/2012/04/configuration-objects-in-scallop.html) about Scallop.

Installation
============

Add following to your build.sbt:

```scala
libraryDependencies += "org.rogach" %% "scallop" % "2.0.1"
```

**Migration from 1.x versions:** `opt[File]` does not check that file exists anymore. Instead, use `validateFileExists` helper inside your configuration.

**Migration from 0.x versions:** due to deprecation of DelayedInit trait, automatic verification
of configuration objects no longer works - now you must call `.verify()` on your config explicitly
before retrieving options.
Also, if you use subcommands, you will have to add them to parent config explicitly by calling
`.addSubcommand()` method.

Quick example
=============

```scala
import org.rogach.scallop._

object Conf extends ScallopConf(List("-c","3","-E","fruit=apple","7.2")) {
  // all options that are applicable to builder (like description, default, etc)
  // are applicable here as well
  val count:ScallopOption[Int] = opt[Int]("count", descr = "count the trees", required = true)
                .map(1+) // also here work all standard Option methods -
                         // evaluation is deferred to after option construction
  val properties = props[String]('E')
  // types (:ScallopOption[Double]) can be omitted, here just for clarity
  val size:ScallopOption[Double] = trailArg[Double](required = false)
  verify()
}
// that's it. Completely type-safe and convenient.
assert(Conf.count() == 4)
assert(Conf.properties("fruit") == Some("apple"))
assert(Conf.size.toOption == Some(7.2))
// passing into other functions
def someInternalFunc(conf:Conf.type) {
  assert(conf.count() == 4)
}
someInternalFunc(Conf)
```

For more examples, you can look at Scallop's [test suite](./src/test/scala).

Fancy things
============

Scallop supports quite powerful matching on trailing arguments. For example:

```scala
object Conf extends ScallopConf(
       List("-Ekey1=value1", "key2=value2", "key3=value3",
            "first", "1","2","3","second","4","5","6")) {
  val props = props[String]('E')
  val firstListName = trailArg[String]()
  val firstList = trailArg[List[Int]]()
  val secondListName = trailArg[String]()
  val secondList = trailArg[List[Double]]()
  verify()
}
Conf.props("key1") should equal (Some("value1"))
Conf.firstListName() should equal ("first")
Conf.secondListName() should equal ("second")
Conf.firstList() should equal (List(1,2,3))
Conf.secondList() should equal (List[Double](4,5,6))
```

In this case, Scallop's backtracking parser is clever enough to distinguish the boundaries of the arguments lists.

Also, Scallop supports parsing of subcommands. Not only subcommands, but nested subcommands!

```scala
object Conf extends ScallopConf(Seq("sub1", "sub2", "sub3", "sub4", "win!")) {
  val sub1 = new Subcommand("sub1") {
    val sub2 = new Subcommand("sub2") {
      val sub3 = new Subcommand("sub3") {
        val sub4 = new Subcommand("sub4") {
          val opts = trailArg[List[String]]()
        }
        addSubcommand(sub4)
      }
      addSubcommand(sub3)
    }
    addSubcommand(sub2)
  }
  addSubcommand(sub1)
  verify()
}
Conf.subcommands should equal (List(Conf.sub1, Conf.sub1.sub2, Conf.sub1.sub2.sub3, Conf.sub1.sub2.sub3.sub4))
Conf.sub1.sub2.sub3.sub4.opts() should equal (List("win!"))
```

Thanks
======
* [Alexy Khrabrov](https://github.com/alexy)

... and the whole Scala community for help and explanations.

Notes
=====

Scallop is distributed under [MIT license](./license.txt).
