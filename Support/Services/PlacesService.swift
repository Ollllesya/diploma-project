//
//  PlacesService.swift
//  Diploma
//
//  Created by Олеся Скидан on 28.04.2025.
//

//  PlacesService.swift
import Alamofire
import CoreLocation
import SwiftyJSON

final class PlacesService {

    private let apiKey: String
    private let sessionToken: String
    private var active: [Request] = []            // ← храним активные запросы

    init(apiKey: String, sessionToken: String = UUID().uuidString) {
        self.apiKey       = apiKey
        self.sessionToken = sessionToken
    }

    // MARK: – Public -----------------------------------------------------------------

    func autocomplete(query: String,
                      around loc: CLLocationCoordinate2D,
                      completion: @escaping (Result<[PlaceResult],Error>) -> Void)
    {
        let enc = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = """
        https://maps.googleapis.com/maps/api/place/autocomplete/json?\
        input=\(enc)&key=\(apiKey)&sessiontoken=\(sessionToken)&\
        components=country:ua&origin=\(loc.latitude),\(loc.longitude)&\
        locationbias=circle:20000@\(loc.latitude),\(loc.longitude)
        """

        let req = AF.request(url)
        track(req)                                // ← добавили
        req.responseData { [weak self] resp in
            self?.untrack(req)                    // ← убрали из массива
            completion(self?.parseAutocomplete(resp) ?? .failure(AFError.explicitlyCancelled))
        }
    }

    func coordinates(for placeId: String,
                     completion: @escaping (Result<CLLocationCoordinate2D,Error>) -> Void)
    {
        let url = """
        https://maps.googleapis.com/maps/api/place/details/json?\
        place_id=\(placeId)&fields=geometry&key=\(apiKey)
        """

        let req = AF.request(url)
        track(req)
        req.responseData { [weak self] resp in
            self?.untrack(req)
            completion(self?.parseCoordinates(resp) ?? .failure(AFError.explicitlyCancelled))
        }
    }

    /// Отменяет ВСЕ ещё работающие запросы
    func cancelAllRunningRequests() {
        active.forEach { $0.cancel() }
        active.removeAll()
    }

    // MARK: – Private ----------------------------------------------------------------

    private func track(_ r: Request)   { active.append(r) }
    private func untrack(_ r: Request) { active.removeAll { $0 === r } }

    private func parseAutocomplete(_ resp: AFDataResponse<Data>) -> Result<[PlaceResult],Error> {
        switch resp.result {
        case .failure(let e): return .failure(e)
        case .success(let d):
            do {
                let json = try JSON(data: d)
                let list = json["predictions"].arrayValue.map {
                    PlaceResult(name: $0["description"].stringValue,
                                placeId: $0["place_id"].stringValue)
                }
                return .success(list)
            } catch { return .failure(error) }
        }
    }

    private func parseCoordinates(_ resp: AFDataResponse<Data>) -> Result<CLLocationCoordinate2D,Error> {
        switch resp.result {
        case .failure(let e): return .failure(e)
        case .success(let d):
            do {
                let json = try JSON(data: d)
                let loc  = json["result"]["geometry"]["location"]
                let c = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue,
                                               longitude: loc["lng"].doubleValue)
                return .success(c)
            } catch { return .failure(error) }
        }
    }
}
