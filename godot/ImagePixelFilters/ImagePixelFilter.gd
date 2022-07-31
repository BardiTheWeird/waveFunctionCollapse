class_name ImagePixelFilter

class ImagePixelFilterBase:
    func is_present(_x: int, _y: int, _size: Vector2) -> bool:
        return false
    
    var eighth = (Vector2.ONE * 16) / 8
    var lower_bound = eighth * 3
    var upper_bound = eighth * 5
    
    func in_bounds(x: int, lo: int, hi: int) -> bool:
        return lo <= x and x < hi
    
    func x_in_bounds(x: int) -> bool:
        return in_bounds(x, lower_bound.x, upper_bound.x)
    
    func y_in_bounds(y: int) -> bool:
        return in_bounds(y, lower_bound.y, upper_bound.y)

class AlwayTrue extends ImagePixelFilterBase:
    func is_present(_x: int, _y: int, _size: Vector2) -> bool:
        return true

class IsInCenterSquare extends ImagePixelFilterBase:
    func is_present(x: int, y: int, _size: Vector2) -> bool:
        if x_in_bounds(x) and y_in_bounds(y):
            return true
        return false

class IsOnVerticalLine extends ImagePixelFilterBase:
    func is_present(x: int, _y: int, _size: Vector2) -> bool:
        return x_in_bounds(x)

class IsOnHorizontalLine extends ImagePixelFilterBase:
    func is_present(_x: int, y: int, _size: Vector2) -> bool:
        return y_in_bounds(y)

class IsOnUpperVerticalLine extends ImagePixelFilterBase:
    func is_present(x: int, y: int, _size: Vector2) -> bool:
        return x_in_bounds(x) and y < upper_bound.y

class IsOnLoverVerticalLine extends ImagePixelFilterBase:
    func is_present(x: int, y: int, _size: Vector2) -> bool:
        return x_in_bounds(x) and y >= lower_bound.y

class IsOnLeftHorizontalLine extends ImagePixelFilterBase:
    func is_present(x: int, y: int, _size: Vector2) -> bool:
        return y_in_bounds(y) and x < upper_bound.x

class IsOnRightHorizontalLine extends ImagePixelFilterBase:
    func is_present(x: int, y: int, _size: Vector2) -> bool:
        return y_in_bounds(y) and x > lower_bound.x
