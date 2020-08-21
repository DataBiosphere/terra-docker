val workbenchUtil2 = "0.10-c3ef6b80-SNAP"

interp.configureCompiler(_.settings.YpartialUnification.value = true)

val circeVersion = "0.13.0"
interp.load.ivy(
  "co.fs2" %% "fs2-io" % "2.4.2",
  "io.circe" %% "circe-core" % circeVersion,
  "io.circe" %% "circe-parser" % circeVersion,
  "io.circe" %% "circe-generic" % circeVersion,
  "io.circe" %% "circe-optics" % circeVersion
)

@

import cats.effect.IO
import java.nio.file.Paths
import java.nio.file.Path

import io.circe.parser._
import io.circe.Printer
import io.circe.Json
import io.circe.syntax._
import io.circe.optics.JsonPath._
import io.circe.generic.semiauto._
import sys.process._
import scala.concurrent.ExecutionContext.global
import cats.effect.Blocker
import fs2.{io, text}
import java.time.Instant
import cats.implicits._

implicit val cs = IO.contextShift(global)
val blocker = Blocker.liftExecutionContext(global)

// Example: oldVersion 1.0.4, newVersion 1.0.5
private def newVersion(oldVersion: String): String = {
  val splited = oldVersion.split("\\.")
  s"${splited(0)}.${splited(1)}.${splited(2).toInt + 1}"
}

val modifyVersion: Json => Json =
  root.version.string.modify {
    s =>
      newVersion(s)
  }

def modifyImageData(imagesToUpdate: List[String]): Json => Json =
  root.image_data.arr.modify {
    listOfImageData =>
      listOfImageData.map {
        image =>
          val imageName = image.hcursor.downField("name").as[String].fold(e => throw e, identity)
          if(imagesToUpdate.contains(imageName))
            modifyVersion(image)
          else image
      }
  }

/**
 * In repo root dir, run `amm ./updateVersion.sc terra-jupyter-base 'update notebook to 6.1.1'`
 * @param updatedImage e.g. "terra-jupyter-base"
 */
@main
def main(updatedImage: String, updatedImageReleaseNote: String): Unit = {
  val imagesToUpdate: List[String] = updatedImage match {
    case "terra-jupyter-base" => List(
      "terra-jupyter-bioconductor",
      "terra-jupyter-hail",
      "terra-jupyter-base",
      "terra-jupyter-python",
      "terra-jupyter-r",
      "terra-jupyter-gatk",
      "terra-jupyter-aou"
    )
    case updatedImage =>
      throw new Exception(s"${updatedImage} is not supported yet. Please update the script to support the image")
  }

  val res = for {
    configFileRawJson <- (io.file.readAll[IO](Paths.get("./config/conf.json"), blocker, 4096).through(text.utf8Decode)).compile.string
    config <- IO.fromEither(parse(configFileRawJson))
    newConfig = modifyImageData(imagesToUpdate)(config)
    _ <- (fs2.Stream.emit(newConfig.asJson.printWith(Printer.spaces4)).covary[IO]
      .through(text.utf8Encode)
      .through(io.file.writeAll(Paths.get("./config/conf.json"), blocker))).compile.drain

    // Update updatedImage's changelog
    updatedImageChangeLogFile = Paths.get(s"${updatedImage}/CHANGELOG.md")
    updatedImageNewVersion <- updateChangeLogFile(
      updatedImage,
      s"""- ${updatedImageReleaseNote}""".stripMargin,
      updatedImageChangeLogFile
    )
    // Update `Dockerfile` and `CHANGELOG.md`
    _ <- imagesToUpdate.filterNot(_.contains(updatedImage)).traverse {
      image =>
        val dockerFileToUpdate = Paths.get(s"${image}/Dockerfile")
        val changelogFile = Paths.get(s"./${image}/CHANGELOG.md")
        for {
          lines <- (io.file.readAll[IO] (dockerFileToUpdate, blocker, 4096)
                    .through(text.utf8Decode)
                    .through(text.lines)).compile.toList
          newLines = lines.zipWithIndex.map {
            lineWithIndex =>
              val s = lineWithIndex._1
              if(s.contains("FROM") && !s.contains("AS")) {
                val firstSplit = s.split(":")
                val splited = firstSplit(1).split("\\.")
                s"${firstSplit(0)}:${splited(0)}.${splited(1)}.${splited(2).toInt + 1}\n"
              } else if(s.contains("AS")) {
                val firstSplit = s.split(":")
                val secondSplit = firstSplit(1).split(" ")
                val splited = secondSplit(0).split("\\.")
                s"${firstSplit(0)}:${splited(0)}.${splited(1)}.${splited(2).toInt + 1} AS python\n"
              } else if(lineWithIndex._2 == lines.length - 1)
                s
              else s"${s}\n"
          }
          _ <- (fs2.Stream.emits(newLines).covary[IO].through(text.utf8Encode)
            .through(io.file.writeAll(dockerFileToUpdate, blocker))).compile.drain

          _ <- updateChangeLogFile(image, s"- Update `${updatedImage}` to `${updatedImageNewVersion}`\n  - ${updatedImageReleaseNote}", changelogFile)
        } yield ()
    }
  } yield ()

  res.unsafeRunSync
}

// returns the new version String of this file
def updateChangeLogFile(image: String, msg: String, path: Path): IO[String] = for {
  originalFileContent <- (io.file.readAll[IO] (path, blocker, 4096)
                                .through(text.utf8Decode)).compile.string
  firstLine = originalFileContent.split("\n")(0)
  newV = newVersion(firstLine.split(" ")(1))
  newFileContent =
  s"""## ${newV} - ${Instant.now()}
     |
     |${msg}
     |
     |Image URL: `us.gcr.io/broad-dsp-gcr-public/${image}:${newV}`
     |
     |${originalFileContent}""".stripMargin
  _ <- (fs2.Stream.emit(newFileContent).covary[IO].through(text.utf8Encode)
    .through(io.file.writeAll(path, blocker))).compile.drain
} yield newV