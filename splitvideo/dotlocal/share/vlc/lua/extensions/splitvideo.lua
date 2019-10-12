--[[
INSTALLATION (create directories if they donot exist):
- put the file in the VLC subdir /lua/extensions, by default:
* Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
* Windows (current user): %APPDATA%\VLC\lua\extensions\
* Linux (all users): /usr/share/vlc/lua/extensions/
* Linux (current user): ~/.local/share/vlc/lua/extensions/
* Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/extensions/
- Restart VLC.
- The extension can then be found in the menu:
    View > Split video in two
- It requires 'splitvideo' from
  https://gitlab.com/ole.tange/tangetools/tree/master/splitvideo
  to be in $PATH
]]--

--[[ Extension description ]]

function descriptor()
  return { title = "SplitVideo" ;
    version = "1.0" ;
    author = "Ole Tange" ;
    shortdesc = "Split video at the current time";
    description = "<h1>Split Video</h1>"
    .. "When you're playing a file, use Split Video to "
    .. "split the file into two files at the current time stamp. " ;
    url = "https://gitlab.com/ole.tange/tangetools/tree/master/splitvideo"
  }
end

--[[ Hooks ]]

-- Activation hook
function activate()
  local filename,secs = filename_secs() ;
  d = vlc.dialog("Split Video") ;
  d:add_label("Split <b>".. filename .. "</b> at <b> " .. secs .. "</b>?") ;
  d:add_button("Split", splitvideo) ;
  d:add_button("Cancel", close) ;
  d:show() ;
  vlc.msg.dbg("[Split Video] Activated") ;
end

function filename_secs()
  -- absolute filename and current play time in seconds
  -- get the current playing file
  local item = vlc.input.item()
  -- extract its URI
  local uri = item:uri()
  -- decode %foo stuff from the URI
  local filename = vlc.strings.decode_uri(uri)
  -- remove 'file://' prefix which is 7 chars long
  filename = string.sub(filename,8)
  -- maybe:
  vlc.msg.dbg("[SplitVideo/filename_secs] Filename " .. filename)
  input = vlc.object.input()
  local elapsed_secs = vlc.var.get(input, "time")/1000000

  return filename,elapsed_secs
end

function splitvideo()
  local filename,secs = filename_secs()
  -- shell quote the filename
  file, _ = filename:gsub("([\002-\009\011-\026\\#?`(){}%[%]^*<>=~|; \"!$&'\130-\255])", "\\%1")
  file, _ = file:gsub("\n", "'\n'")
  os.execute("splitvideo " .. secs .. " " .. file)
  close()
end


function deactivate()
  -- Deactivation hook
  vlc.msg.dbg("[SplitVideo] Deactivated")
  vlc.deactivate()
end

function close()
  deactivate()
end

-- This empty function is there, because vlc pested me otherwise
function meta_changed()
end
