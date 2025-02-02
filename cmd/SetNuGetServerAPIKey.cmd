@ECHO OFF

REM **** These API Keys to be kept private

SET NUGETSERVERAPIKEY=

IF "%~1" == "Create" (
  SET NUGETSERVERAPIKEY=oy2oxcrh2ho32p4qkdxqhkzrfyyfobsuflm5pqzykxp6na
)

IF "%~1" == "DNX.GlobalHotKeys" (
  SET NUGETSERVERAPIKEY=oy2fo3dom7ufv73f4seas4gzevk2mqeuzaapz6eguqmgja
)
IF "%~1" == "DNX.Griffin.AdoNetFakes" (
  SET NUGETSERVERAPIKEY=oy2icdt7bockunpeeb4qtvg6cs2jiynubmm52tgoz6gzby
)
IF "%~1" == "DNX.Helpers" (
  SET NUGETSERVERAPIKEY=oy2bpy5oyjdysn37theq3pkkumzrylhudmtux7xumrqlga
)
IF "%~1" == "DNX.Helpers.CommandLine" (
  SET NUGETSERVERAPIKEY=oy2csppvpaqx7edyohza275xg3s3v3nu7i35aynl3rxuhm
)
IF "%~1" == "DNX.Helpers.Console" (
  SET NUGETSERVERAPIKEY=oy2ggwagjcblb3o7nw5qzda3xsxhmzjuxc2qnswtjjfwfi
)
IF "%~1" == "DNX.Helpers.Log4Net" (
  SET NUGETSERVERAPIKEY=oy2acxz4xbrahgs4dxoqbm6jsnyuotae3dzrjbeagos3xm
)
