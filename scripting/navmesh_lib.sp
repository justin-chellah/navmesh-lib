#include <sourcemod>
#include <sdktools>

#define GAMEDATA_FILE   "navmesh_lib"

Address TheNavMesh = Address_Null;

// unsigned int CNavArea::m_masterMarker = 1;
Address CNavArea_m_masterMarker = Address_Null;

Handle g_hSDKCall_CNavMesh_GetNavArea = null;
Handle g_hSDKCall_TerrorNavArea_GetNextEscapeStep = null;
Handle g_hSDKCall_TerrorNavArea_IsValidForWanderingPopulation = null;

int g_iCNavArea_m_center = -1;
int g_iCNavArea_m_isUnderwater = -1;
int g_iCNavArea_m_marker = -1;
int g_iCNavArea_m_attributeFlags = -1;
int g_iTerrorNavMesh_m_flMaxFlowDistance = -1;
int g_iTerrorNavArea_m_fPotentiallyVisibleToSurvivorFlags = -1;
int g_iTerrorNavArea_m_spawnAttributeFlags = -1;

// CNavArea *GetNavArea( const Vector &pos, float beneathLimt = 120.0f ) const
public any Native_CNavMesh_GetNavArea( Handle hPlugin, int nParams )
{
    float pos[3];
    GetNativeArray( 1, pos, sizeof( pos ) );
    float beneathLimit = GetNativeCell( 2 );
    return SDKCall( g_hSDKCall_CNavMesh_GetNavArea, TheNavMesh, pos, beneathLimit );
}

public any Native_TerrorNavMesh_GetMaxFlowDistance( Handle hPlugin, int nParams )
{
    return LoadFromAddress( TheNavMesh + view_as< Address >( g_iTerrorNavMesh_m_flMaxFlowDistance ), NumberType_Int32 );
}

// int GetAttributes( void ) const
public int Native_CNavArea_GetAttributes( Handle hPlugin, int nParams )
{
    Address adrArea = GetNativeCell( 1 );
    return LoadFromAddress( view_as< Address >( adrArea ) + view_as< Address >( g_iCNavArea_m_attributeFlags ), NumberType_Int32 );
}

// bool IsUnderwater( void ) const
public any Native_CNavArea_IsUnderwater( Handle hPlugin, int nParams )
{
    Address adrArea = GetNativeCell( 1 );
    return LoadFromAddress( view_as< Address >( adrArea ) + view_as< Address >( g_iCNavArea_m_isUnderwater ), NumberType_Int8 );
}

// const Vector &GetCenter( void ) const
public int Native_CNavArea_GetCenter( Handle hPlugin, int nParams )
{
    Address adrArea = GetNativeCell( 1 );
    float flVecCenter[3];
    flVecCenter[0] = LoadFromAddress( adrArea + view_as< Address >( g_iCNavArea_m_center ), NumberType_Int32 );
    flVecCenter[1] = LoadFromAddress( adrArea + view_as< Address >( g_iCNavArea_m_center + 4 ), NumberType_Int32 );
    flVecCenter[2] = LoadFromAddress( adrArea + view_as< Address >( g_iCNavArea_m_center + 8 ), NumberType_Int32 );
    SetNativeArray( 2, flVecCenter, sizeof( flVecCenter ) );
    return 1;
}

// static void MakeNewMarker( void )
public int Native_CNavArea_MakeNewMarker( Handle hPlugin, int nParams )
{
    // ++m_masterMarker; if (m_masterMarker == 0) m_masterMarker = 1;
    int m_masterMarker = LoadFromAddress( CNavArea_m_masterMarker, NumberType_Int32 );
    ++m_masterMarker;
    StoreToAddress( CNavArea_m_masterMarker, m_masterMarker, NumberType_Int32 );
    if ( m_masterMarker == 0 )
    {
        StoreToAddress( CNavArea_m_masterMarker, 1, NumberType_Int32 );
    }

    return 1;
}

// bool IsMarked( void ) const
public any Native_CNavArea_IsMarked( Handle hPlugin, int nParams )
{
    Address adrArea = GetNativeCell( 1 );
    int m_marker = LoadFromAddress( adrArea + view_as< Address >( g_iCNavArea_m_marker ), NumberType_Int32 );
    int m_masterMarker = LoadFromAddress( CNavArea_m_masterMarker, NumberType_Int32 );
    return ( m_marker == m_masterMarker );
}

// void Mark( void )
public int Native_CNavArea_Mark( Handle hPlugin, int nParams )
{
    Address adrArea = GetNativeCell( 1 );
    int m_masterMarker = LoadFromAddress( CNavArea_m_masterMarker, NumberType_Int32 );
    StoreToAddress( adrArea + view_as< Address >( g_iCNavArea_m_marker ), m_masterMarker, NumberType_Int32 );
    return 1;
}

public any Native_TerrorNavArea_GetNextEscapeStep( Handle hPlugin, int nParams )
{
    Address adrFromArea = GetNativeCell( 1 );
    int nHow;
    Address adrAreaOnEscapeRoute = SDKCall( g_hSDKCall_TerrorNavArea_GetNextEscapeStep, adrFromArea, nHow );
    SetNativeCellRef( 2, nHow );
    return adrAreaOnEscapeRoute;
}

public any Native_TerrorNavArea_IsValidForWanderingPopulation( Handle hPlugin, int nParams )
{
    Address adrArea = GetNativeCell( 1 );
    return SDKCall( g_hSDKCall_TerrorNavArea_IsValidForWanderingPopulation, adrArea );
}

public any Native_TerrorNavArea_GetPotentiallyVisibleToSurvivorFlags( Handle hPlugin, int nParams )
{
    Address adrArea = GetNativeCell( 1 );
    return LoadFromAddress( view_as< Address >( adrArea ) + view_as< Address >( g_iTerrorNavArea_m_fPotentiallyVisibleToSurvivorFlags ), NumberType_Int8 );
}

public int Native_TerrorNavArea_GetSpawnAttributes( Handle hPlugin, int nParams )
{
    Address adrArea = GetNativeCell( 1 );
    return LoadFromAddress( view_as< Address >( adrArea ) + view_as< Address >( g_iTerrorNavArea_m_spawnAttributeFlags ), NumberType_Int32 );
}

public void OnPluginStart()
{
    GameData hGameData = new GameData( GAMEDATA_FILE );
    if ( hGameData == null )
    {
        SetFailState( "Unable to load gamedata file \"" ... GAMEDATA_FILE ... "\"" );
    }

#define GET_ADDRESS_WRAPPER(%0,%1)\
    %1 = hGameData.GetAddress(%0);\
    if (%1 == Address_Null)\
    {\
        delete hGameData;\
        SetFailState("Unable to find gamedata address entry or signature in binary for \"" ... %0 ... "\"");\
    }

#define GET_OFFSET_WRAPPER(%0,%1)\
    %1 = hGameData.GetOffset(%0);\
    if (%1 == -1)\
    {\
        delete hGameData;\
        SetFailState("Unable to find gamedata offset entry for \"" ... %0 ... "\"");\
    }

    GET_ADDRESS_WRAPPER( "TerrorNavMesh instance", TheNavMesh )
    GET_ADDRESS_WRAPPER( "CNavArea::m_masterMarker", CNavArea_m_masterMarker )

    GET_OFFSET_WRAPPER( "CNavArea::m_center", g_iCNavArea_m_center )
    GET_OFFSET_WRAPPER( "CNavArea::m_isUnderwater", g_iCNavArea_m_isUnderwater )
    GET_OFFSET_WRAPPER( "CNavArea::m_marker", g_iCNavArea_m_marker )
    GET_OFFSET_WRAPPER( "CNavArea::m_attributeFlags", g_iCNavArea_m_attributeFlags )
    GET_OFFSET_WRAPPER( "TerrorNavMesh::m_flMaxFlowDistance", g_iTerrorNavMesh_m_flMaxFlowDistance )
    GET_OFFSET_WRAPPER( "TerrorNavArea::m_fPotentiallyVisibleToSurvivorFlags", g_iTerrorNavArea_m_fPotentiallyVisibleToSurvivorFlags )
    GET_OFFSET_WRAPPER( "TerrorNavArea::m_spawnAttributeFlags", g_iTerrorNavArea_m_spawnAttributeFlags )

#define PREP_SDKCALL_SET_FROM_CONF_SIGNATURE_WRAPPER(%0)\
    if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, %0)) \
    {\
        delete hGameData;\
        SetFailState("Unable to find gamedata signature entry or signature in binary for \"" ... %0 ... "\"");\
    }

    StartPrepSDKCall( SDKCall_Raw );
    PREP_SDKCALL_SET_FROM_CONF_SIGNATURE_WRAPPER( "CNavMesh::GetNavArea" )
    PrepSDKCall_SetReturnInfo( SDKType_PlainOldData, SDKPass_Plain );
    PrepSDKCall_AddParameter( SDKType_Vector, SDKPass_ByRef );          // const Vector &pos
    PrepSDKCall_AddParameter( SDKType_Float, SDKPass_Plain );           // float beneathLimit
    g_hSDKCall_CNavMesh_GetNavArea = EndPrepSDKCall();

    StartPrepSDKCall( SDKCall_Raw );
    PREP_SDKCALL_SET_FROM_CONF_SIGNATURE_WRAPPER( "TerrorNavArea::GetNextEscapeStep" )
    PrepSDKCall_SetReturnInfo( SDKType_PlainOldData, SDKPass_Plain );
    PrepSDKCall_AddParameter( SDKType_PlainOldData, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL, VENCODE_FLAG_COPYBACK );   // NavTraverseType *pNavTraverseType
    g_hSDKCall_TerrorNavArea_GetNextEscapeStep = EndPrepSDKCall();

    StartPrepSDKCall( SDKCall_Raw );
    PREP_SDKCALL_SET_FROM_CONF_SIGNATURE_WRAPPER( "TerrorNavArea::IsValidForWanderingPopulation" )
    PrepSDKCall_SetReturnInfo( SDKType_Bool, SDKPass_Plain );
    g_hSDKCall_TerrorNavArea_IsValidForWanderingPopulation = EndPrepSDKCall();

    delete hGameData;
}

public APLRes AskPluginLoad2( Handle hMyself, bool bLate, char[] szError, int nErrMax )
{
    RegPluginLibrary( "navmesh_lib" );
    CreateNative( "CNavMesh.GetNavArea", Native_CNavMesh_GetNavArea );
    CreateNative( "TerrorNavMesh.GetMaxFlowDistance", Native_TerrorNavMesh_GetMaxFlowDistance );
    CreateNative( "CNavArea.GetAttributes", Native_CNavArea_GetAttributes );
    CreateNative( "CNavArea.IsUnderwater", Native_CNavArea_IsUnderwater );
    CreateNative( "CNavArea.GetCenter", Native_CNavArea_GetCenter );
    CreateNative( "CNavArea.MakeNewMarker", Native_CNavArea_MakeNewMarker );
    CreateNative( "CNavArea.IsMarked", Native_CNavArea_IsMarked );
    CreateNative( "CNavArea.Mark", Native_CNavArea_Mark );
    CreateNative( "TerrorNavArea.GetNextEscapeStep", Native_TerrorNavArea_GetNextEscapeStep );
    CreateNative( "TerrorNavArea.IsValidForWanderingPopulation", Native_TerrorNavArea_IsValidForWanderingPopulation );
    CreateNative( "TerrorNavArea.m_fPotentiallyVisibleToSurvivorFlags.get", Native_TerrorNavArea_GetPotentiallyVisibleToSurvivorFlags );
    CreateNative( "TerrorNavArea.GetSpawnAttributes", Native_TerrorNavArea_GetSpawnAttributes );
    return APLRes_Success;
}

public Plugin myinfo =
{
    name = "[L4D2] NavMesh Library",
    author = "Justin \"Sir Jay\" Chellah",
    description = "Provides some useful functions from the NavMesh library",
    version = "1.0.0",
    url = "https://www.justin-chellah.com"
};