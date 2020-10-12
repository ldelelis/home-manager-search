plan
====

1. Load modules via import `<home-manager/modules>`
2. Access its modules via `options`
3. For each module:
   1. Filter down its options. They should match the following:
      * _type = "option"
      * visible = true
      * internal = false
   2. Grab its module path, as JSON key. It can be fetched from `<module>.enable.loc`
   3. Extract into json:
      * `description`
      * `type.description`
   4. Extract if they exist:
      * `default`
      * `example`
   5. Write all into JSON
4. With resulting JSON, generate html files. Path should be each key


json structure
==============

{
  "path.to.module": {
    "description": "text"
    "type": "some weird object"
    "example": "asdadasdsadsadasd"
  },
  "path.to.other.deeper.module": {
    ...
  },
  ...
}


HTML module structure
=====================

<body>
honestly idk here help me out
</body>


Channels
========

Two separate channels should be searchable:
  * home-manager master
  * current stable release (20.03 at the time of writing this)

issues
------

* How to keep master up to date?
* How to make adding new releases easy?
* Should we track old releases? how many? how long?


Build process
=============

The nix snippet will be in charge of populating a json file with the required data

how to generate html files with said json? another nix script? other language?


Search mechanism
================

A search engine will be written in rescript. it should take a string as input, and output a list of fuzzy? matching modules, linking to its documentation file

issues
------

How to build the list of available modules? should we use the generated json? performance? should we cache keys in memory as soon as the page loads? how to implement fuzzy search? should we even?
