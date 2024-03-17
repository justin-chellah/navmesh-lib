# [L4D2] NavMesh Library
This is a SourceMod Plugin that exposes some useful functions from the `CNavMesh`, `TerrorNavMesh`, `CNavArea` and `TerrorNavArea` classes.

# API
```
methodmap CNavArea
{
    public native int GetAttributes();
    public native bool IsUnderwater();
    public native int GetCenter( float flVecCenterOut[3] );

    /*
     * Adds a new marker which is then used to flag certain areas as already checked,
     * usually used by the A* pathfinding algorithm.
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
```

# Requirements
- [SourceMod 1.11+](https://www.sourcemod.net/downloads.php?branch=stable)

# Supported Platforms
- Windows
- Linux

# Supported Games
- Left 4 Dead 2