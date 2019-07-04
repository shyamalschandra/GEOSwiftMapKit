import GEOSwift
import MapKit

public extension CLLocationCoordinate2D {
    init(_ point: Point) {
        self.init(latitude: point.y, longitude: point.x)
    }
}

extension Point {
    public init(longitude: Double, latitude: Double) {
        self.init(x: longitude, y: latitude)
    }

    public init(_ coordinate: CLLocationCoordinate2D) {
        self.init(x: coordinate.longitude, y: coordinate.latitude)
    }
}

public extension MKPointAnnotation {
    convenience init(point: Point) {
        self.init()
        coordinate = CLLocationCoordinate2D(point)
    }
}

public extension MKPlacemark {
    convenience init(point: Point) {
        self.init(coordinate: CLLocationCoordinate2D(point), addressDictionary: nil)
    }
}

public extension MKPolyline {
    convenience init(lineString: LineString) {
        var coordinates = lineString.points.map(CLLocationCoordinate2D.init)
        self.init(coordinates: &coordinates, count: coordinates.count)
    }
}

public extension MKPolygon {
    convenience init(linearRing: GEOSwift.Polygon.LinearRing) {
        var coordinates = linearRing.points.map(CLLocationCoordinate2D.init)
        self.init(coordinates: &coordinates, count: coordinates.count)
    }

    convenience init(polygon: GEOSwift.Polygon) {
        var exteriorCoordinates = polygon.exterior.points.map(CLLocationCoordinate2D.init)
        self.init(
            coordinates: &exteriorCoordinates,
            count: exteriorCoordinates.count,
            interiorPolygons: polygon.holes.map(MKPolygon.init))
    }
}

open class GeometryMapShape: MKShape, MKOverlay {
    let geometry: GeometryConvertible

    private let _coordinate: CLLocationCoordinate2D
    override open var coordinate: CLLocationCoordinate2D {
        return _coordinate
    }

    public let boundingMapRect: MKMapRect

    public init(geometry: GeometryConvertible) throws {
        self.geometry = geometry
        self._coordinate = try CLLocationCoordinate2D(geometry.centroid())
        let envelope = try geometry.envelope()
        let topLeft = MKMapPoint(CLLocationCoordinate2D(envelope.topLeft))
        let bottomRight = MKMapPoint(CLLocationCoordinate2D(envelope.bottomRight))
        self.boundingMapRect = MKMapRect(
            origin: topLeft,
            size: MKMapSize(
                width: bottomRight.x - topLeft.x,
                height: bottomRight.y - topLeft.y))
    }
}