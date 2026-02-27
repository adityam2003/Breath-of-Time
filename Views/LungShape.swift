import SwiftUI

// MARK: - LungLobe

/// One lung lobe (RIGHT orientation). Flip with scaleEffect(x:-1) for left.
/// Static shape — animation is handled by LungView via scaleEffect.
/// `widthScale` provides anatomical asymmetry (right ≈ 1.0, left ≈ 0.88).
struct LungLobe: Shape {

    var widthScale: Double = 1.0

    func path(in rect: CGRect) -> Path {
        let w = rect.width  * CGFloat(widthScale)
        let h = rect.height

        // Maps normalised coords into the rect.
        // Inner edge (x=0) is pinned to left of frame; outer expands right.
        func p(_ nx: CGFloat, _ ny: CGFloat) -> CGPoint {
            CGPoint(x: nx * w, y: ny * h)
        }

        var path = Path()

        // ── 1. Bronchus root (inner-top) ─────────────────────────────────
        path.move(to: p(0.00, 0.20))

        // ── 2. Top taper → apex ──────────────────────────────────────────
        // control1 hugs inward (gentle taper near trachea attach), then sweeps wide
        path.addCurve(
            to:       p(0.74, 0.03),
            control1: p(0.07, 0.09),   // inward hold — creates top taper
            control2: p(0.46, -0.03)
        )

        // ── 3. Apex → shoulder (slight inward shoulder detail) ────────────
        // control2 pulls slightly inward before the shoulder break
        path.addCurve(
            to:       p(0.91, 0.26),
            control1: p(0.93, 0.03),
            control2: p(0.96, 0.14)
        )

        // ── 4. Shoulder → upper-mid (very subtle inward concavity) ────────
        // control1 nudges slightly inward at ~35% — creates the gentle mid-body variation
        path.addCurve(
            to:       p(0.90, 0.46),
            control1: p(0.94, 0.33),
            control2: p(0.92, 0.40)
        )

        // ── 5. Upper-mid → widest lateral ────────────────────────────────
        path.addCurve(
            to:       p(0.93, 0.60),
            control1: p(0.91, 0.50),
            control2: p(0.95, 0.55)
        )

        // ── 6. Widest → lower flare (fuller bottom) ───────────────────────
        path.addCurve(
            to:       p(0.78, 0.82),
            control1: p(0.96, 0.68),
            control2: p(0.92, 0.76)
        )

        // ── 7. Diaphragm base — deep rounded dome ────────────────────────
        // control1 pushed well below the rect for a more pronounced dome curve
        path.addCurve(
            to:       p(0.00, 0.90),
            control1: p(0.60, 1.08),
            control2: p(0.24, 0.98)
        )

        // ── 8. Mediastinal edge — single smooth S-curve (no corners) ─────
        path.addCurve(
            to:       p(0.00, 0.20),
            control1: p(0.22, 0.74),
            control2: p(0.11, 0.40)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - TracheaShape

/// Trachea + carina fork. Slimmer tube, more curved bronchi, tapered ends.
struct TracheaShape: Shape {

    var breathingFactor: Double = 1.0

    var animatableData: Double {
        get { breathingFactor }
        set { breathingFactor = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let cw = rect.width
        let ch = rect.height
        let s  = CGFloat(breathingFactor)

        // Slimmer tube
        let hw: CGFloat   = 0.020 * cw          // half-width (was 0.032 — reduced ~37%)
        let cx: CGFloat   = cw * 0.5
        let tubeTop: CGFloat = 0
        let carinaY: CGFloat = ch * 0.58 * s    // where fork starts
        let leftX:   CGFloat = cx - cw * 0.185 * s
        let rightX:  CGFloat = cx + cw * 0.185 * s

        // Bronchi taper: they narrow at their tips
        let branchBot: CGFloat = carinaY + ch * 0.42 * s
        let tipW:      CGFloat = hw * 1.1        // tip width at lung entry

        var path = Path()

        // ── Left outer wall of tube downward ─────────────────────────────
        path.move(to:    CGPoint(x: cx - hw, y: tubeTop))
        path.addLine(to: CGPoint(x: cx - hw, y: carinaY))

        // Left bronchus — curves outward with tight arc (well-curved fork)
        path.addCurve(
            to:       CGPoint(x: leftX,        y: branchBot),
            control1: CGPoint(x: cx - hw,      y: carinaY + ch * 0.22 * s),
            control2: CGPoint(x: leftX,        y: carinaY + ch * 0.10 * s)
        )

        // Taper at lung entry: bronchus tip (left)
        path.addLine(to: CGPoint(x: leftX + tipW, y: branchBot))

        // Inner wall of left bronchus back toward carina — curved
        path.addCurve(
            to:       CGPoint(x: cx,           y: carinaY + ch * 0.12 * s),
            control1: CGPoint(x: leftX + tipW, y: carinaY + ch * 0.16 * s),
            control2: CGPoint(x: cx,           y: carinaY + ch * 0.22 * s)
        )

        // Inner wall of right bronchus out to tip — curved
        path.addCurve(
            to:       CGPoint(x: rightX - tipW, y: branchBot),
            control1: CGPoint(x: cx,            y: carinaY + ch * 0.22 * s),
            control2: CGPoint(x: rightX - tipW, y: carinaY + ch * 0.16 * s)
        )

        // Taper: right tip
        path.addLine(to: CGPoint(x: rightX, y: branchBot))

        // Right bronchus outer wall back up to carina
        path.addCurve(
            to:       CGPoint(x: cx + hw,  y: carinaY),
            control1: CGPoint(x: rightX,   y: carinaY + ch * 0.10 * s),
            control2: CGPoint(x: cx + hw,  y: carinaY + ch * 0.22 * s)
        )

        // Right outer wall of tube back to top
        path.addLine(to: CGPoint(x: cx + hw, y: tubeTop))
        path.closeSubpath()

        return path
    }
}
