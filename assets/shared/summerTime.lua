    function onCreatePost()
        if (summerTime) then
            initLuaShader("sandstorm");

            makeLuaSprite("temporaryShader");
            makeGraphic("temporaryShader", screenWidth, screenHeight);
            
            setSpriteShader("temporaryShader", "sandstorm");
            
            addHaxeLibrary("ShaderFilter", "openfl.filters");
            runHaxeCode([[
                trace(ShaderFilter);
                game.camGame.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader)]);
                game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader)]);
            ]]);
        end
    end

    function onUpdatePost()
        if (summerTime) then
            setShaderFloat('temporaryShader','iTime',os.clock())
        end
    end
