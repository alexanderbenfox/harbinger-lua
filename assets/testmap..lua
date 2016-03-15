return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.14.2",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 20,
  height = 20,
  tilewidth = 32,
  tileheight = 32,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "tileset_wip___01_by_smilecythe-d4cmmwg",
      firstgid = 1,
      tilewidth = 32,
      tileheight = 32,
      spacing = 2,
      margin = 5,
      image = "../../../MapStringGenerator/tileset_wip___01_by_smilecythe-d4cmmwg.png",
      imagewidth = 613,
      imageheight = 563,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 272,
      tiles = {}
    },
    {
      name = "simpletiles1",
      firstgid = 273,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "simpletiles1.png",
      imagewidth = 128,
      imageheight = 64,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 8,
      tiles = {
        {
          id = 1,
          properties = {
            ["tilevalue"] = "D"
          }
        },
        {
          id = 5,
          properties = {
            ["tilevalue"] = "p"
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "Background",
      x = 0,
      y = 0,
      width = 20,
      height = 20,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJxjYGRgYIRiJiphRiqbyUhjM0eKG5HNpaZ5o3gUj+KRiQE+HgSb"
    },
    {
      type = "tilelayer",
      name = "Tile Layer 1",
      x = 0,
      y = 0,
      width = 20,
      height = 20,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["tileproperty"] = "b"
      },
      encoding = "base64",
      compression = "zlib",
      data = "eJzrZGBg6KQyphYYquapQjEx4ixQjM88cgGtzcPmR2IBCxbzcAFi7aGlf3HFJyEwlOMXBMiNY1Lil1hAC/PUgFgdCYsyovJhYsji6HxkbA7EFlTEHkDsSUUcCcRRVMQA68Ev9w=="
    },
    {
      type = "tilelayer",
      name = "BlocksAndPushables",
      x = 0,
      y = 0,
      width = 20,
      height = 20,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["tileproperty"] = "notb"
      },
      encoding = "base64",
      compression = "zlib",
      data = "eJxjYBh6QIgRgokRx6aO1uYNBoDLP8SqJUcNOWopBbjiDpdaappHLUBtOwezeTCzBsI8sSGSd4cSAACwNwJ4"
    }
  }
}
