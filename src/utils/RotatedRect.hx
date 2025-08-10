package utils;

import h2d.col.Point;

class RotatedRect {
    public var center: Point;
    public var width: Float;
    public var height: Float;
    public var angle: Float; // in degrees

    public function new(x: Float, y: Float, width: Float, height: Float, angle: Float = 0){
        this.center = new Point(x, y);
        this.width = width;
        this.height = height;
        this.angle = angle;
    }

    public function getCorners(){
        var radians = angle*(Math.PI / 180);
        var cosA = Math.cos(radians);
        var sinA = Math.sin(radians);
        var halfW = width/2;
        var halfH = height/2;
        var corners = [
            new Point(-halfW, -halfH), // Top-left
             new Point( halfW, -halfH), // Top-right
            new Point( halfW, halfH), // Bottom-right
            new Point(-halfW,halfH)  // Bottom-left
        ];

        for (p in corners){
            var xNew = p.x * cosA - p.y * sinA + center.x;
            var yNew = p.x * sinA + p.y * cosA + center.y;
            p.set(xNew, yNew);
        }

        return corners;
    }

    public function containsPoint(point: Point){
        var radians = -angle * (Math.PI / 180);
        var cosA = Math.cos(radians);
        var sinA = Math.sin(radians);
        var localX = (point.x-center.x) * cosA - (point.y-center.y) * sinA;
        var localY = (point.x-center.x) * sinA + (point.y-center.y) * cosA;
        var halfW = width / 2;
        var halfH = height / 2;
        
        return (localX >= -halfW && localX <= halfW && localY >= -halfH && localY <= halfH);
    }

    public function collidesWith(other: RotatedRect){
        var cornersA = this.getCorners();
        var cornersB = other.getCorners();
        return satCollision(cornersA, cornersB);
    }

    static function satCollision(polyA: Array<Point>, polyB: Array<Point>){
        var axes = getAxes(polyA).concat(getAxes(polyB));

        for (axis in axes){
            var projA = projectPolygon(polyA, axis);
            var projB = projectPolygon(polyB, axis);
            if (projA.max < projB.min || projB.max < projA.min) {
                return false;
            }
        }
        return true;
    }

    static function getAxes(poly: Array<Point>){
        var axes = [];
        for (i in 0...poly.length){
            var p1 = poly[i];
            var p2 = poly[(i + 1) % poly.length];
            var edge = new Point(p2.x-p1.x, p2.y-p1.y);
            var normal = new Point(-edge.y, edge.x);
            normal.normalize();
            axes.push(normal);
        }
        return axes;
    }

    static function projectPolygon(poly: Array<Point>, axis: Point){
        var min = poly[0].dot(axis);
        var max = min;
        for (i in 1...poly.length){
            var projection = poly[i].dot(axis);
            if (projection < min) min = projection;
            if (projection > max) max = projection;
        }
        return { min: min, max: max };
    }
}
