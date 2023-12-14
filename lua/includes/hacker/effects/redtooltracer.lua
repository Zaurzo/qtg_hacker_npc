local function HackerRedToolTracer_Register()
    local hackerbeam = file.Read('gamemodes/base/entities/effects/tooltracer.lua','GAME')

    hackerbeam = string.Replace(hackerbeam,'Color( 255, 255, 255, 128','Color(255,16,16,128')
    hackerbeam = string.Replace(hackerbeam,'color_white','Color(255,16,16)')

    effects.Register(CompileString('local EFFECT = {}' .. hackerbeam .. '\nreturn EFFECT')(),'Hacker_RedToolTracer')
end

timer.Simple(0,HackerRedToolTracer_Register)