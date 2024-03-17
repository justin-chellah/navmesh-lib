#if defined _navmesh_lib_included
 #endinput
#endif
#define _navmesh_lib_included

enum NavAttributeType
{
    NAV_MESH_INVALID        = 0,
    NAV_MESH_CROUCH         = 0x0000001,				// must crouch to use this node/area
    NAV_MESH_JUMP           = 0x0000002,				// must jump to traverse this area (only used during generation)
    NAV_MESH_PRECISE        = 0x0000004,				// do not adjust for obstacles, just move along area
    NAV_MESH_NO_JUMP        = 0x0000008,				// inhibit discontinuity jumping
    NAV_MESH_STOP           = 0x0000010,				// must stop when entering this area
    NAV_MESH_RUN            = 0x0000020,				// must run to traverse this area
    NAV_MESH_WALK           = 0x0000040,				// must walk to traverse this area
    NAV_MESH_AVOID          = 0x0000080,				// avoid this area unless alternatives are too dangerous
    NAV_MESH_TRANSIENT      = 0x0000100,				// area may become blocked, and should be periodically checked
    NAV_MESH_DONT_HIDE      = 0x0000200,				// area should not be considered for hiding spot generation
    NAV_MESH_STAND          = 0x0000400,				// bots hiding in this area should stand
    NAV_MESH_NO_HOSTAGES    = 0x0000800,				// hostages shouldn't use this area
    NAV_MESH_STAIRS         = 0x0001000,				// this area represents stairs, do not attempt to climb or jump them - just walk up
    NAV_MESH_NO_MERGE       = 0x0002000,				// don't merge this area with adjacent areas
    NAV_MESH_OBSTACLE_TOP   = 0x0004000,				// this nav area is the climb point on the tip of an obstacle
    NAV_MESH_CLIFF          = 0x0008000,				// this nav area is adjacent to a drop of at least CliffHeight

    NAV_MESH_FIRST_CUSTOM   = 0x00010000,				// apps may define custom app-specific bits starting with this value
    NAV_MESH_LAST_CUSTOM    = 0x04000000,				// apps must not define custom app-specific bits higher than with this value

    NAV_MESH_HAS_ELEVATOR   = 0x40000000,				// area is in an elevator's path
    NAV_MESH_NAV_BLOCKER    = 0x80000000				// area is blocked by nav blocker ( Alas, needed to hijack a bit in the attributes to get within a cache line [7/24/2008 tom])
};

// enum CNavArea::TerrorNavAttributeType
enum TerrorNavAttributeType
{
    NAV_TANK_ONLY           = 0x00010000,
    NAV_MOB_ONLY            = 0x00020000,

    // Left 4 Dead 2 only
    NAV_PLAYERCLIP          = 0x00040000,
    NAV_BREAKABLEWALL       = 0x00080000,
    NAV_FLOW_BLOCKED        = 0x08000000,
    NAV_OUTSIDE_WORLD       = 0x10000000,
    NAV_MOSTLY_FLAT         = 0x20000000,
};

// https://developer.valvesoftware.com/wiki/List_of_L4D_Series_Nav_Mesh_Attributes
enum TerrorNavSpawnAttributeType
{
    SPAWN_INVALID               = 0,
    SPAWN_EMPTY                 = 0x0000002,
    SPAWN_STOP                  = 0x0000004,
    SPAWN_BATTLESTATION         = 0x0000020,
    SPAWN_FINALE                = 0x0000040,
    SPAWN_PLAYER_START          = 0x0000080,
    SPAWN_BATTLEFIELD           = 0x0000100,
    SPAWN_IGNORE_VISIBILITY     = 0x0000200,
    SPAWN_NOT_CLEARABLE         = 0x0000400,
    SPAWN_CHECKPOINT            = 0x0000800,
    SPAWN_OBSCURED              = 0x0001000,
    SPAWN_NO_MOBS               = 0x0002000,
    SPAWN_THREAT                = 0x0004000,
    SPAWN_RESCUE_VEHICLE        = 0x0008000,
    SPAWN_RESCUE_CLOSET         = 0x0010000,
    SPAWN_ESCAPE_ROUTE          = 0x0020000,
    SPAWN_DOOR                  = 0x0040000,

    // Left 4 Dead 2 only
    SPAWN_NOTHREAT              = 0x0080000,
    SPAWN_LYINGDOWN             = 0x0100000,
    SPAWN_COMPASS_NORTH         = 0x1000000,
    SPAWN_COMPASS_NORTHEAST     = 0x2000000,
    SPAWN_COMPASS_EAST          = 0x4000000,
    SPAWN_COMPASS_EASTSOUTH     = 0x8000000,
    SPAWN_COMPASS_SOUTH         = 0x10000000,
    SPAWN_COMPASS_SOUTHWEST     = 0x20000000,
    SPAWN_COMPASS_WEST          = 0x40000000,
    SPAWN_COMPASS_WESTNORTH     = 0x80000000
};

enum NavTraverseType
{
    NavTraverseType_North = 0,
    NavTraverseType_East,
    NavTraverseType_South,
    NavTraverseType_West,

    NavTraverseType_LadderUp,
    NavTraverseType_LadderDOwn,
    NavTraverseType_Jump,
    NavTraverseType_ElevatorUp,
    NavTraverseType_ElevatorDown,
};

enum TerrorNavAreaFlowType
{
    TerrorNavAreaFlow_TowardGoal        = 0,
    TerrorNavAreaFlow_AwayFromStart
};

enum TerrorNavAreaVisibleToType
{
    TerrorNavAreaVisibleTo_NamVet       = 0x1,  // Bill or Nick
    TerrorNavAreaVisibleTo_TeenGirl     = 0x2,  // Zoey or Rochelle
    TerrorNavAreaVisibleTo_Manager      = 0x4,  // Louis or Coach
    TerrorNavAreaVisibleTo_Biker        = 0x8   // Francis or Ellis
};

methodmap CNavArea
{
    public native int GetAttributes();
    public native bool IsUnderwater();
    public native int GetCenter( float flVecCenterOut[3] );

    /*
     * Adds a new marker which is then used to mark specific areas as already checked,
     * typically used by the A* pathfinding algorithm.
     */
    public static native void MakeNewMarker();

    public native bool IsMarked();
    public native void Mark();
};

methodmap CNavMesh
{
    /*
     * Given a position, return the nav area that IsOverlapping and is *immediately* beneath it.
     */
    public static native CNavArea GetNavArea( float flVecPos[3], float flBeneathLimit = 120.0 );
};

methodmap TerrorNavArea < CNavArea
{
    /*
     * @param eTraverseType     (Optional) How this area is traversed.
     */
    public native TerrorNavArea GetNextEscapeStep( NavTraverseType& eTraverseType = view_as<NavTraverseType>( 0 ) );

    /*
     * Returns true if these conditions are met:
     *
     * Area is not blocked for the infected team.
     * Area doesn't have attribute NAV_MESH_CROUCH and NAV_MESH_JUMP flags.
     * Area doesn't have attribute NAV_TANK_ONLY and NAV_MOB_ONLY flags.
     * Area doesn't have spawn SPAWN_RESCUE_CLOSET, SPAWN_CHECKPOINT, SPAWN_PLAYER_START, and SPAWN_EMPTY flags.
     * Flow isn't broken (the area's flow distance away from the player start isn't negative).
     */
    public native bool IsValidForWanderingPopulation();

    property TerrorNavAreaVisibleToType m_fPotentiallyVisibleToSurvivorFlags
    {
        public native get();
    }

    public native int GetSpawnAttributes();
};

methodmap TerrorNavMesh < CNavMesh
{
    public static native float GetMaxFlowDistance();
};

public SharedPlugin __pl_navmesh_lib =
{
    name = "navmesh_lib",
    file = "navmesh_lib.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_navmesh_lib_SetNTVOptional()
{
    MarkNativeAsOptional( "CNavMesh.GetNavArea" );
    MarkNativeAsOptional( "CNavMesh.GetAttributes" );
    MarkNativeAsOptional( "CNavMesh.IsUnderwater" );
    MarkNativeAsOptional( "CNavMesh.GetCenter" );
    MarkNativeAsOptional( "CNavMesh.MakeNewMarker" );
    MarkNativeAsOptional( "CNavMesh.IsMarked" );
    MarkNativeAsOptional( "CNavMesh.Mark" );
    MarkNativeAsOptional( "TerrorNavMesh.GetMaxFlowDistance" );
    MarkNativeAsOptional( "TerrorNavArea.GetNextEscapeStep" );
    MarkNativeAsOptional( "TerrorNavArea.IsValidForWanderingPopulation" );
    MarkNativeAsOptional( "TerrorNavArea.m_fPotentiallyVisibleToSurvivorFlags.get" );
    MarkNativeAsOptional( "TerrorNavArea.GetSpawnAttributes" );
}
#endif