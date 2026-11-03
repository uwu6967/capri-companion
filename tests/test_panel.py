"""Exercise the panel in LuaJIT with a mocked game API; no live game control."""
import json
import os
from pathlib import Path
from tempfile import TemporaryDirectory
from lupa.luajit21 import LuaRuntime

SOURCE = (Path(__file__).resolve().parents[1] / "src" / "init.lua").read_text(encoding="utf-8")


def boot():
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().py_decode = lambda text: lua.table_from(json.loads(text))
    lua.globals().py_encode = lambda table: json.dumps(dict(table.items()))
    lua.execute('''
      events, inputs, configured, commands, edits = {}, {}, {}, {}, {}
      function registerForEvent(name, fn) events[name] = fn end
      function registerInput(name, label, fn) inputs[name] = fn end
      json = {decode = py_decode, encode = py_encode}
      player, system = {}, {qolConfigured = false}
      Game = {GetPlayer = function() return player end}
      CapriSummonSystem = {Get = function() return system end}
      function system:ConfigureQOL(...) configured[#configured+1] = {...}; self.qolConfigured = true end
      function system:QOLStatus(p) return 'Helpers: 2/3' end
      function system:QOLRegroup(p) commands[#commands+1] = 'regroup'; return 'Regrouped' end
      function system:QOLToggleFollowing(p) commands[#commands+1] = 'follow'; return 'Toggled' end
      function system:QOLTalk(p) commands[#commands+1] = 'talk'; return 'Talking' end
      ImGuiWindowFlags = {AlwaysAutoResize = 64}
      ImGui = {
        Begin = function() return true end, End = function() end,
        Text = function() end, TextWrapped = function() end,
        Separator = function() end, SameLine = function() end,
        Button = function() return false end,
        Checkbox = function(label, current)
          if edits[label] then edits[label] = nil; return not current, true end
          return current, false
        end,
        SliderFloat = function(label, current) return current, false end
      }
    ''')
    api = lua.execute(SOURCE)
    lua.globals().events.onInit()
    return lua, api


def test_panel():
    previous = Path.cwd()
    with TemporaryDirectory() as directory:
        os.chdir(directory)
        try:
            lua, api = boot()
            g = lua.globals()
            clean = api.sanitize(lua.table_from({"chatter": False, "autoStrike": False, "uploadMin": 4, "uploadMax": 1}))
            assert clean.chatter is False and clean.autoStrike is False
            assert clean.uploadMin == clean.uploadMax == 4
            clean = api.sanitize(lua.table_from({"uploadMin": float("nan"), "uploadMax": 100}))
            assert clean.uploadMin == 1 and clean.uploadMax == 5
            g.events.onUpdate(0.5)
            assert len(g.configured) == 1
            assert g.configured[1][2] is False, "Automatic attacks must default OFF"
            g.events.onUpdate(0.5)
            assert len(g.configured) == 1, "Do not reapply every update"
            g.inputs.capri_regroup(False)
            assert len(g.commands) == 0, "Ignore key release"
            g.inputs.capri_regroup(True)
            g.inputs.capri_follow(True)
            g.inputs.capri_talk(True)
            assert [g.commands[i] for i in range(1, 4)] == ["regroup", "follow", "talk"]
            g.inputs.capri_auto_strike(True)
            assert g.configured[len(g.configured)][2] is True
            assert json.loads(Path("settings.json").read_text())["autoStrike"] is True
            g.events.onOverlayOpen()
            g.inputs.capri_regroup(True)
            assert len(g.commands) == 3, "Do not fire gameplay inputs while editing the panel"
            g.edits["Random Capri chatter (subtitles)"] = True
            g.events.onDraw()
            assert json.loads(Path("settings.json").read_text())["chatter"] is False
            g.events.onOverlayClose()
            # Saved OFF values must survive a complete reload.
            lua2, _ = boot()
            lua2.globals().events.onUpdate(0.5)
            loaded = lua2.globals().configured[1]
            assert loaded[1] is False and loaded[2] is True
            lua2.execute("player = nil")
            lua2.globals().events.onUpdate(0.5)
            lua2.globals().inputs.capri_talk(True)
            assert len(lua2.globals().commands) == 0
            # Malformed settings must not prevent normal defaults from loading.
            Path("settings.json").write_text("not json")
            lua3, _ = boot()
            lua3.globals().events.onUpdate(0.5)
            assert lua3.globals().configured[1][1] is True
            Path("settings.json").write_text(json.dumps({"autoStrike": True}))
            lua4, _ = boot()
            lua4.globals().events.onUpdate(0.5)
            assert lua4.globals().configured[1][2] is False, "Old enabled preferences must migrate OFF"
            print("PASS: LuaJIT load, preferences, bounds, UI toggles, input guards, reload, no player, corrupt settings")
        finally:
            os.chdir(previous)


if __name__ == "__main__":
    test_panel()
