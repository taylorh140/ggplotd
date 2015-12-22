
interface graphicsContext{

/**
 * Makes a copy of the current state of cr and saves it on an
 * internal stack of saved states for cr. When $(D Context.restore())
 * is called, cr will be restored to the saved state. Multiple
 * calls to $(D Context.save()) and  $(D Context.restore()) can be nested; each
 * call to  $(D Context.restore()) restores the state from the matching
 * paired $(D Context.save()).
 *
 * It isn't necessary to clear all saved states before a $(D Context)
 * is freed. If the reference count of a $(D Context) drops to zero
 * , any saved states will be freed along with the $(D Context).
 */
 	void save(){}
 
/**
 * Restores cr to the state saved by a preceding call to
 * $(D Context.save()) and removes that state from the stack of
 * saved states.
 */
  void restore(){} 
 
  /**
 * Resets the current transformation matrix (CTM) by setting it
 * equal to the identity matrix. That is, the user-space and
 * device-space axes will be aligned and one user-space unit
 * will transform to one device-space unit.
 */
 	void identityMatrix(){}
 	
 /**
 * Adds a closed sub-path rectangle of the given size to the
 * current path at position r.point in user-space coordinates.
 * This function is logically equivalent to:
 * ---------------------
 * cr.moveTo(r.point);
 * cr.relLineTo(r.width, 0);
 * cr.relLineTo(0, r.height);
 * cr.relLineTo(-r.width, 0);
 * cr.closePath();
 * ---------------------
 */
 	void rectangle(double left,double top, double width,double height){};
 	
/**
 * Sets the source pattern within cr to a translucent color.
 * This color will then be used for any subsequent drawing
 * operation until a new source pattern is set.
 *
 * The color and alpha components are floating point numbers in
 * the range 0 to 1. If the values passed in are outside that
 * range, they will be clamped.
 *
 * The default source pattern is opaque black, (that is, it is
 * equivalent to setSourceRGBA(0.0, 0.0, 0.0, 1.0)).
 */
 void setSourceRGBA(RGBA nativeRGBA){}
 //Use this -> void setSourceRGBA(double red, double green, double blue, double alpha){}
 
 /**
 * A drawing operator that fills the current path according to
 * the current fill rule, (each sub-path is implicitly closed
 * before being filled). After c$(D fill()), the current
 * path will be cleared from the cairo context. See
 * $(D setFillRule()) and $(D fillPreserve()).
 */
void fill(){}
 	
 /**
 * Begin a new sub-path. After this call the current point will be p1.
 */
void moveTo(double x, double y){}

 /**
 * Adds a line to the path from the current point to position p1
 * in user-space coordinates. After this call the current point
 * will be p1.
 *
 * If there is no current point before the call to $(D lineTo())
 * this function will behave as $(D moveTo(p1)).
 *
 * Params:
 * p1 = End of the line
 */
void lineTo(double x, double y){}

/**
 * A drawing operator that fills the current path according to
 * the current fill rule, (each sub-path is implicitly closed
 * before being filled). Unlike $(D fill()), $(D fillPreserve())
 * preserves the path within the cairo context.
 */
void fillPreserve(){}
/**
 * A drawing operator that strokes the current path according to
 * the current line width, line join, line cap, and dash settings.
 * After $(D stroke()), the current path will be cleared from
 * the cairo context. See $(D setLineWidth()),
 * $(D setLineJoin()), $(D setLineCap()), $(D setDash()),
 * and $(D strokePreserve()).
 *
 * Note: Degenerate segments and sub-paths are treated specially
 * and provide a useful result. These can result in two
 * different situations:
 *
 * 1. Zero-length "on" segments set in cairo_set_dash(). If the
 * cap style is CAIRO_LINE_CAP_ROUND or CAIRO_LINE_CAP_SQUARE
 * then these segments will be drawn as circular dots or squares
 * respectively. In the case of CAIRO_LINE_CAP_SQUARE, the
 * orientation of the squares is determined by the direction
 * of the underlying path.
 *
 * 2. A sub-path created by $(D moveTo()) followed by either a
 * $(D closePath()) or one or more calls to $(D lineTo()) to
 * the same coordinate as the $(D moveTo()). If the cap style
 * is CAIRO_LINE_CAP_ROUND then these sub-paths will be drawn as
 * circular dots. Note that in the case of CAIRO_LINE_CAP_SQUARE
 * a degenerate sub-path will not be drawn at all, (since the
 * correct orientation is indeterminate).
 *
 * In no case will a cap style of CAIRO_LINE_CAP_BUTT cause
 * anything to be drawn in the case of either degenerate
 * segments or sub-paths.
 */
void stroke(){}
/**
 * Applies rotation by radians to the transformation in matrix.
 * The effect of the new transformation is to first rotate the
 * coordinates by radians, then apply the original transformation
 * to the coordinates.
 *
 * Params:
 * radians = angle of rotation, in radians. The direction of
 * rotation is defined such that positive angles rotate in the
 * direction from the positive X axis toward the positive Y axis.
 * With the default axis orientation of cairo, positive angles
 * rotate in a clockwise direction.
 */
void rotate(double radians){}
/**
 * Sets the current font matrix to a scale by a factor of size,
 * replacing any font matrix previously set with $(D setFontSize())
 * or $(D setFontMatrix()). This results in a font size of
 * size user space units. (More precisely, this matrix will
 * result in the font's em-square being a size by size
 * square in user space.)
 *
 * If text is drawn without a call to $(D setFontSize()),
 * (nor $(D setFontMatrix()) nor $(D setScaledFont())),
 * the default font size is 10.0.
 *
 * Params:
 * size = the new font size, in user space units
 */
void setFontSize(double size){}
/**
 * Gets the extents for a string of text. The extents describe
 * a user-space rectangle that encloses the "inked"
 * portion of the text, (as it would be drawn by $(D showText())).
 * Additionally, the x_advance and y_advance values indicate
 * the amount by which the current point would be advanced
 * by $(D showText()).
 *
 * Note that whitespace characters do not directly contribute
 * to the size of the rectangle (extents.width and extents.height).
 * They do contribute indirectly by changing the position of
 * non-whitespace characters. In particular, trailing whitespace
 * characters are likely to not affect the size of the rectangle,
 * though they will affect the x_advance and y_advance values.
 */

 Extents textExtents(string text){}
 
 /**
 * A drawing operator that generates the shape from a string of
 * UTF-8 characters, rendered according to the current
 * fontFace, fontSize (fontMatrix), and fontOptions.
 *
 * This function first computes a set of glyphs for the string
 * of text. The first glyph is placed so that its origin is
 * at the current point. The origin of each subsequent glyph
 * is offset from that of the previous glyph by the advance
 * values of the previous glyph.
 *
 * After this call the current point is moved to the origin
 * of where the next glyph would be placed in this same
 * progression. That is, the current point will be at the
 * origin of the final glyph offset by its advance values.
 * This allows for easy display of a single logical string
 * with multiple calls to $(D showText()).
 *
 * Note: The $(D showText()) function call is part of
 * what the cairo designers call the "toy" text API. It
 * is convenient for short demos and simple programs, but
 * it is not expected to be adequate for serious text-using
 * applications. See $(D showGlyphs()) for the "real" text
 * display API in cairo.
 */
void showText(string text){}

	/**
	 * Begin a new sub-path. After this call the current point will
	 * offset by rp1.
	 *
	 * Given a current point of (x, y), cairo_rel_move_to(cr, dx, dy)
	 * is logically equivalent to cairo_move_to(cr, x + dx, y + dy).
	 *
	 * It is an error to call this function with no current point.
	 * Doing so will cause an CairoException with a status of
	 * CAIRO_STATUS_NO_CURRENT_POINT.
	 */
	void relMoveTo(double x, double y){}

/**
 * Transform a coordinate from device space to user space by
 * multiplying the given point by the inverse of the current
 * transformation matrix (CTM).
 */
  Point deviceToUser(Point inp){}
}

 struct Extents{int width, int height};
 Point {double x, double y};
