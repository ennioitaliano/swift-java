# Design Notes

## Task #1
I started this basic implementation of Kotlin code generation by looking at the already existing Java translation logic used in `jexctract` mode, pruning the parts that were out of scope for the task at hand.

Because of this design choice, my implementation:
- reuses the existing Swift parsing/analysis pipeline (`Swift2JavaTranslator` + `AnalysisResult`)
- reuses existing `mode` configuration and CLI plumbing
- reuses existing output/file-list infrastructure (output dirs, package path handling, generated sources list)

This has allowed me to cut a bit the time spent for this first task. Also, this way I had to handle less code surface and fewer failure modes, obtaining cheaper maintenance/testing in case shared extraction logic evolves (e.g., for Task #2).

I wouldn't say this is ideal, though. In fact, one still needs to call the command with the old `jextract` syntax, leading to some quirks like using `--output-java` and `--java-package` options to specify Kotlin output path and optional package name. 

Also, if I had more time, I'd probably implement this from scratch in a separate part of the codebase and with a different CLI UX (like `--lang kotlin-jvm` / `--emit kotlin-jvm` as suggested by the assignment). Beyond the reasons already mentioned, in fact, I don't think that `kotlin` belongs to a `jextract` `mode` at the same level of `jni` and `ffm` from a semantics point of view. 

Another corner I had to cut to make the most out of the available time is about error handling. In my implementation, if a Swift declaration uses anything unsupported, translation throws an error which is logged at debug level ("Failed to translate..."), and that function is skipped while generation continues.

A more complete solution would ideally support additional types alongside classes, structs, and local functions. For unsupported types though, one option would be to translate them to `Unit` with an inline comment indicating what happened and what the original type was. Another alternative would be to preserve the unsupported type name as-is while commenting out the entire block it belongs to (e.g., the function declaration and body).

## Task #2
To extend the results of the previous task, I chose to make the generated Kotlin code actually callable by connecting it to the existing JNI runtime used by the project.

The legacy JNI approach has been chosen over the FFM one because of its wider compatibility. In particular, old JVM's and Android systems can be supported by this mode, which made it look like a reasonable choice for Swift-to-Kotlin translation. 

The main limitations of JNI mode are about performance and flexibility, in which FFM proves to be better, at the expense of being available only for newer JDK versions. An ideal solution would support both JNI and FFM, allowing the user to select the preferred mode.

Another (minor) design choice concerns mapping implicit Swift `Void` (which I left out in Task #1) to explicit Kotlin `Unit`. This is not the most idiomatic Kotlin way, but I think it is better for clarity and stability in generated code. For prettier output, I’d drop explicit `: Unit` and maybe use expression bodies for wrappers; also, the long per-method generator-location comments could be removed (or gated behind a debug flag).

In tackling this task, I also noticed that JNI thunk generation maps Swift `Int` to JVM `long`, while Swift `Int` was translated to Kotlin `Int` instead. To make Kotlin output fully consistent/functional for `Int`-typed Swift APIs, I changed the translation logic to use Kotlin `Long`, while `Int32` is still translated to Kotlin `Int`. 