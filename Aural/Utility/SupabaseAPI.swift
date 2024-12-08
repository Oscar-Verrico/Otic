import Foundation

class SupabaseAPI {
    static let shared = SupabaseAPI()

    private init() {}

    // Upload a file to Supabase Storage
    func uploadFile(bucket: String, fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let uploadURL = "\(SupabaseConfig.baseURL)/storage/v1/object/\(bucket)/\(fileURL.lastPathComponent)"
        var request = URLRequest(url: URL(string: uploadURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(SupabaseConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let fileData = try? Data(contentsOf: fileURL)

        let task = URLSession.shared.uploadTask(with: request, from: fileData) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                let publicURL = "\(SupabaseConfig.baseURL)/storage/v1/object/public/\(bucket)/\(fileURL.lastPathComponent)"
                completion(.success(publicURL))
            } else {
                completion(.failure(NSError(domain: "Upload failed", code: 0, userInfo: nil)))
            }
        }
        task.resume()
    }

    // Fetch files from a Supabase Storage bucket
    func fetchFiles(bucket: String, completion: @escaping ([URL]) -> Void) {
        let listURL = "\(SupabaseConfig.baseURL)/storage/v1/object/list/\(bucket)"
        var request = URLRequest(url: URL(string: listURL)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(SupabaseConfig.apiKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let files = try JSONDecoder().decode([File].self, from: data)
                    let urls = files.compactMap { file in
                        URL(string: "\(SupabaseConfig.baseURL)/storage/v1/object/public/\(bucket)/\(file.name)")
                    }
                    completion(urls)
                } catch {
                    print("Error decoding files: \(error)")
                    completion([])
                }
            } else {
                print("Error fetching files: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
            }
        }
        task.resume()
    }
}

// Model for Supabase file list
struct File: Codable {
    let name: String
}
