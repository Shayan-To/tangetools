--[[
INSTALLATION (create directories if they donot exist):
- put the file in the VLC subdir /lua/extensions, by default:
* Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
* Windows (current user): %APPDATA%\VLC\lua\extensions\
* Linux (all users): /usr/share/vlc/lua/extensions/
* Linux (current user): ~/.local/share/vlc/lua/extensions/
* Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/extensions/
- Restart VLC.
- The extension can then be found in the menu View > Wastebasket.
]]--

--[[ Extension description ]]

function descriptor()
  return { title = "Wastebasket" ;
    version = "0.9" ;
    author = "Mark Morschhäuser/Ole Tange" ;
    shortdesc = "Move current playing file into wastebasket";
    description = "<h1>Wastebasket</h1>"
    .. "When you're playing a file, use Wastebasket to "
    .. "easily move this file to a .waste-dir with one click. "
    .. "<br>This will NOT change your playlist, it will move the file itself. "
    .. "<br>Wastebasket will search for a dir called .waste "
    .. "in the dir of the file and all parent dirs of that.";
    url = "https://gitlab.com/ole.tange/tangetools/wastebasket"
  }
end

--[[ Hooks ]]

-- Activation hook
function activate()
  -- get the current playing file
  item = vlc.input.item()
  -- extract its URI
  uri = item:uri()
  -- decode %foo stuff from the URI
  filename = vlc.strings.decode_uri(uri)
  -- remove 'file://' prefix which is 7 chars long
  filename = string.sub(filename,8)

  -- find .waste in parent dirs
  wdir = wastedir(dirname(filename))
  if(directory_exists(wdir)) then
    d = vlc.dialog("Wastebasket")
    d:add_label("Move <b>".. filename .. "</b> to <b>" .. wdir .. "</b>?")
    d:add_button("Move", delete)
    d:add_button("Cancel", close)
    d:show()
  else
    d = vlc.dialog("Wastebasket - no dir found")
    d:add_label(".waste is not found anywhere in parent dirs")
    d:add_button("Cancel", close)
    d:show()
  end
  vlc.msg.dbg("[Wastebasket] Activated")
end

function wastedir(dir)
  -- recursively search for .waste in parent dir

  vlc.msg.dbg("[Wastebasket/wastedir] Looking at " .. dir)
  wdir = dir .. "/" .. ".waste"
  if directory_exists(wdir) then
     vlc.msg.dbg("[Wastebasket/wastedir] Found wastedir: " .. wdir)
     return wdir
  end
  -- try the parent dir
  parent = dirname(dir)
  vlc.msg.dbg("[Wastebasket/wastedir] parent " .. parent)
  if directory_exists(parent) then
    return wastedir(parent)
  else
    return parent
  end
end

function directory_exists(dir)
  -- Simple checker if dir exists
  return os.execute("cd " .. dir)
end

function deactivate()
  -- Deactivation hook
  vlc.msg.dbg("[Wastebasket] Deactivated")
  vlc.deactivate()
end

function close()
  deactivate()
end

--- Function equivalent to basename in POSIX systems
--@param str the path string
function basename(str)
  local name = string.gsub(str, "(.*/)(.*)", "%2")
  return name
end

function dirname(str)
  local name = string.gsub(str, "(.*)/(.*)", "%1")
  return name
end

function delete()
  -- get the current playing file
  item = vlc.input.item()
  -- extract its URI
  uri = item:uri()
  -- decode %foo stuff from the URI
  filename = vlc.strings.decode_uri(uri)
  -- remove 'file://' prefix which is 7 chars long
  filename = string.sub(filename,8)

  -- find .waste in parent dirs
  wdir = wastedir(dirname(filename))
  if(directory_exists(wdir)) then
    basena = basename(filename)
    dst = wdir .. "/" .. basena
    vlc.msg.dbg("[Wastebasket]: Move to " .. dst)
    retval, err = os.rename(filename,dst)
    if(retval == nil) then
      -- error handling; if deletion failed, print why
      vlc.msg.dbg("[Wastebasket] error: " .. err)
    end
  else
    d = vlc.dialog("Wastebasket - no dir found")
    d:add_label(".waste is not found anywhere in parent dirs")
    d:add_button("Cancel", close)
    d:show()
  end
  close()
end

-- This empty function is there, because vlc pested me otherwise
function meta_changed()
end
