// Feather disable all

#macro __MSDF_DPI_GM_TO_NORMATIVE  (4/3)

__MsdfSystem();

function __MsdfSystem()
{
    static _system = {};
    if (_system != undefined) return _system;
    
    _system = {};
    with(_system)
    {
        __MsdfTrace("Welcome to Msdf by Juju Adams! This is version 1.0.0, 2025-10-27");
    }
    
    return _system;
}