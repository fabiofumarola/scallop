include(macro.m4)
### Breaking change
This release introduces a breaking change - opt[File] no longer checks that supplied file exists
(because it is common to provide output file as an argument).

### Improvements
* Added option to enable appending of default option values to option description (I(103)).
* Suppress "trailing arguments" from output if all trailing args are hidden (githubUser(Jesse Kinkead,jkinkead), I(106)).
* Do not run validation functions if no options are provided, instead fall back to default values (I(108)).
* Improved error messages for common converter types (githubUser(Jesse Kinkead,jkinkead), I(111)).
* Added ScallopOption.toOption, deprecated ScallopOption.get to avoid confusion with native Scala Option methods (I(112)).
* Added java.nio.Path converter (githubUser(Jesse Kinkead,jkinkead), I(114)).
