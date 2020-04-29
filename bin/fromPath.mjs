#!/usr/bin/env node

import { mkdirSync, readFileSync, realpathSync, writeFileSync } from "fs"
import { basename, dirname } from "path"
import { generate } from "./js/generate.mjs"

Promise.resolve(process.argv.slice(2))
  .then(main)
  .then(a => {
    process.stdout.write(a)
    process.exit()
  })
  .catch(a => {
    process.stderr.write(String(a))
    process.exit(1)
  })

/**
 * @param {string[]} a
 * @returns {Promise<string>}
 */
async function main(a) {
  if (a.length === 0) {
    throw "Usage: elm-json-interop [file.elm ...]"
  }
  const result = await Promise.all(a.map(processFile))
  return result.join("\n")
}

/**
 * @param {string} a
 * @returns {Promise<string>}
 */
async function processFile(a) {
  const path = realpathSync(a)

  const content = readFileSync(path, { encoding: "utf8" })
  const [encode, decode, ts] = await generate(content)

  const elmBasename = basename(path, ".elm")
  const targetFolder = getTargetFolder(path)

  mkdirSync(targetFolder, { recursive: true })
  writeFileSync(targetFolder + "/" + elmBasename + "Encode.elm", encode)
  writeFileSync(targetFolder + "/" + elmBasename + "Decode.elm", decode)
  writeFileSync(targetFolder + "/" + elmBasename + ".ts", ts)

  return "I have generated JSON encoders/decoders and TypeScript definitions in folder:\n" + targetFolder
}

/**
 * @param {string} a
 * @returns {string}
 */
function getTargetFolder(a) {
  if (!a.includes("/src/")) throw new Error("Folder called 'src' must be within file path.")
  return dirname(a.replace(/^(.*)\/src\/(.*)$/, "$1/src/Generated/$2"))
}