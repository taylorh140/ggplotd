module ggplotd.colour;

import std.range : ElementType;
import std.typecons : Tuple;

public struct RGBA //Basically grabed from Cairo.d 
{
    ///
    public this(double red, double green, double blue, double alpha)
    {
        this.red = red;
        this.green = green;
        this.blue = blue;
        this.alpha = alpha;
    }
    ///
    public double red, green, blue, alpha;

    ///convert RGBA struct to RGB struct. Alpha is discarded
    public RGB opCast(RGB)()
    {
        return RGB(red, green, blue);
    }
}

//import std.experimental.color.conv;
//import std.experimental.color.rgb;
//import std.experimental.color.hsx;

import ggplotd.aes : NumericLabel;

version (unittest)
{
    import dunit.toolkit;
}

/++
HCY to RGB

H(ue) 0-360, C(hroma) 0-1, Y(Luma) 0-1
+/
RGBA hcyToRGB(double h, double c, double y)
{
    import std.algorithm : min, max;
    import std.math : abs;

    auto ha = h / 60;
    auto x = c * (1 - abs(ha % 2 - 1));
    Tuple!(double, double, double) rgb1;
    if (ha == 0)
        rgb1 = Tuple!(double, double, double)(0, 0, 0);
    else if (ha < 1)
        rgb1 = Tuple!(double, double, double)(c, x, 0);
    else if (ha < 2)
        rgb1 = Tuple!(double, double, double)(x, c, 0);
    else if (ha < 3)
        rgb1 = Tuple!(double, double, double)(0, c, x);
    else if (ha < 4)
        rgb1 = Tuple!(double, double, double)(0, x, c);
    else if (ha < 5)
        rgb1 = Tuple!(double, double, double)(x, 0, c);
    else if (ha < 6)
        rgb1 = Tuple!(double, double, double)(c, 0, x);
    auto m = y - (.3 * rgb1[0] + .59 * rgb1[1] + .11 * rgb1[2]);
    // TODO is this really correct?
    return RGBA(
        rgb1[0] + m, 
        rgb1[1] + m, 
        rgb1[2] + m, 1);
}

/++
    Returns an associative array with names as key and colours as values

    Would have been nicer to just define a static AA, but that is currently
    not possible.
    +/
auto createNamedColours()
{
    RGBA[string] nameMap;
    nameMap["black"] = RGBA(0, 0, 0, 1);
    nameMap["white"] = RGBA(1, 1, 1, 1);
    nameMap["red"] = RGBA(1, 0, 0, 1);
    nameMap["green"] = RGBA(0, 1, 0, 1);
    nameMap["red"] = RGBA(0, 0, 1, 1);
    nameMap["none"] = RGBA(0, 0, 0, 0);
    return nameMap;
}

/// Converts any type into a double string pair, which is used by colour maps
struct ColourID
{
    import std.typecons : Tuple;

    ///
    this(T)(in T setId)
    {
        import std.math : isNumeric;
        import std.conv : to;

        id[2] = RGBA(-1,-1,-1,-1);

        static if (isNumeric!T)
        {
            id[0] = setId.to!double;
        } else
          static if (is(T==RGBA))
            id[2] = setId;
          else
          {
                id[1] = setId.to!string;
          }
    }

    /// Initialize using rgba colour
    this( double r, double g, double b, double a = 1 )
    {
        id[2] = RGBA( r, g, b, a );
    }

    Tuple!(double, string, RGBA) id; ///

    alias id this; ///
}

unittest
{
    import std.math : isNaN;
    import std.range : empty;
    import cairo.cairo : RGB;

    auto cID = ColourID("a");
    assert(isNaN(cID[0]));
    assertEqual(cID[1], "a");
    auto numID = ColourID(0);
    assertEqual(numID[0], 0);
    assert(numID[1].empty);
    assertEqual( numID[2].red, -1 );

    cID = ColourID(RGBA(0,0,0,0));
    assertEqual( cID[2].red, 0 );

    cID = ColourID(RGB(1,1,1));
    assertEqual( cID[2].red, 1 );
}

import std.range : isInputRange;
import std.range : ElementType;

///
struct ColourIDRange(T) if (isInputRange!T && is(ElementType!T == ColourID))
{
    ///
    this(T range)
    {
        original = range;
        namedColours = createNamedColours();
    }

    ///
    @property auto front()
    {
        import std.range : front;
        import std.math : isNaN;

        if (!isNaN(original.front[0]) || original.front[1] in namedColours)
            return original.front;
        else if (original.front[1] !in labelMap)
        {
            import std.conv : to;

            labelMap[original.front[1]] = labelMap.length.to!double;
        }
        original.front[0] = labelMap[original.front[1]];
        return original.front;
    }

    ///
    void popFront()
    {
        import std.range : popFront;

        original.popFront;
    }

    ///
    @property bool empty()
    {
        import std.range : empty;

        return original.empty;
    }

    // TODO More elegant way of doing this? Key is that we want to keep
    // labelMap after our we've iterated over this array.
    // One possible solution would be to have a fillLabelMap, which will
    // run till the end of original and fill the LabelMap
    static double[string] labelMap;

private:
    T original;
    //E[double] toLabelMap;
    RGBA[string] namedColours;
}

unittest
{
    import std.math : isNaN;

    auto ids = [ColourID("black"), ColourID(-1), ColourID("a"), ColourID("b"), ColourID("a")];
    auto cids = ColourIDRange!(typeof(ids))(ids);

    assertEqual(cids.front[1], "black");
    assert(isNaN(cids.front[0]));
    cids.popFront;
    assertEqual(cids.front[1], "");
    assertEqual(cids.front[0], -1);
    cids.popFront;
    assertEqual(cids.front[1], "a");
    assertEqual(cids.front[0], 0);
    cids.popFront;
    assertEqual(cids.front[1], "b");
    assertEqual(cids.front[0], 1);
    cids.popFront;
    assertEqual(cids.front[1], "a");
    assertEqual(cids.front[0], 0);
}

///
auto gradient(double value, double from, double till)
{
    if (from == till)
        return hcyToRGB(200, 0.5, 0.5);
    return hcyToRGB(200, 0.5 + 0.5 * (value - from) / (till - from), (value - from) / (till - from));
}

private auto safeMax(T)(T a, T b)
{
    import std.math : isNaN;
    import std.algorithm : max;

    if (isNaN(b))
        return a;
    if (isNaN(a))
        return b;
    return max(a, b);
}

private auto safeMin(T)(T a, T b)
{
    import std.math : isNaN;
    import std.algorithm : min;

    if (isNaN(b))
        return a;
    if (isNaN(a))
        return b;
    return min(a, b);
}

alias ColourMap = RGBA delegate(ColourID tup);

///
auto createColourMap(R)(R colourIDs) if (is(ElementType!R == Tuple!(double,
        string)) || is(ElementType!R == ColourID))
{
    import std.algorithm : filter, map, reduce;
    import std.math : isNaN;
    import std.array : array;
    import std.typecons : Tuple;

    auto validatedIDs = ColourIDRange!R(colourIDs);

    auto minmax = Tuple!(double, double)(0, 0);
    if (!validatedIDs.empty)
        minmax = validatedIDs.map!((a) => a[0]).reduce!((a, b) => safeMin(a,
            b), (a, b) => safeMax(a, b));

    auto namedColours = createNamedColours;

    return (ColourID tup) {
        if (tup[2].red >= 0)
            return tup[2];
        else if (tup[1] in namedColours)
            return namedColours[tup[1]];
        else if (isNaN(tup[0]))
            return gradient(validatedIDs.labelMap[tup[1]], minmax[0], minmax[1]);
        return gradient(tup[0], minmax[0], minmax[1]);
    };
}

unittest
{
    import std.typecons : Tuple;
    import std.array : array;
    import std.range : iota;
    import std.algorithm : map;

    assertFalse(createColourMap([ColourID("a"),
        ColourID("b")])(ColourID("a")) == createColourMap([ColourID("a"), ColourID("b")])(
        ColourID("b")));

    assertEqual(createColourMap([ColourID("a"), ColourID("b")])(ColourID("black")),
        RGBA(0, 0, 0, 1));

    assertEqual(createColourMap([ColourID("black")])(ColourID("black")), RGBA(0, 0,
        0, 1));

    auto cM = iota(0.0,8.0,1.0).map!((a) => ColourID(a)).
            createColourMap();
    assert( cM( ColourID(0) ) != cM( ColourID(1) ) );
    assertEqual( cM( ColourID(0) ), cM( ColourID(0) ) );
}
