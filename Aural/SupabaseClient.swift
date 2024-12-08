//
//  SupabaseClient.swift
//  Aural
//
//  Created by Oscar Verrico on 12/6/24.
//


import Supabase
import Foundation

class SupabaseClient {
    static let shared = SupabaseClient()

    private let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
    private let supabaseKey = "YOUR_SUPABASE_KEY"
    private var client: SupabaseClient

    private init() {
        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    func getClient() -> SupabaseClient {
        return client
    }
}
