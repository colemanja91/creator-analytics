class TwitchGraphqlService
  # Twitch's GraphQL API is undocumented,
  # so use of this service is risky.

  # Twitch's Helix API does not expose Follow Count
  # and the "Get User Follows" endpoint is deprecated
  # so this is the best option.
  def get_user(user_id)
    query = <<-GRAPHQL
      query {
        user(id: "#{user_id}") {
          id
          login
          createdAt
          roles {
            isPartner
            isAffiliate
          }
          followers {
            totalCount
          }
        }
      }
    GRAPHQL

    run_query(query)["data"]
  end

  private

  def run_query(query)
    begin
      result = conn(integrity_token).post("gql", {"query" => query}.to_json)
    rescue Faraday::Error => e
      puts e.response[:status]
      puts e.response[:body]
    end

    JSON.parse(result.body)
  end

  def integrity_token
    refresh_integrity_token!
    @integrity_token
  end

  def integrity_token_valid?
    current_time = Time.now.strftime("%s%L").to_i

    defined?(@integrity_token) && defined?(@integrity_expiration) && @integrity_expiration > (current_time + 5000)
  end

  def refresh_integrity_token!
    return if integrity_token_valid?
    begin
      result = conn.post("integrity")
    rescue Faraday::Error => e
      puts e.response[:status]
      puts e.response[:body]
    end

    json = JSON.parse(result.body)

    token = json.fetch("token")
    expiration = json.fetch("expiration")

    if token.nil? || expiration.nil?
      raise StandardError.new("Could not generate integrity token: #{json}")
    end

    @integrity_token = token
    @integrity_expiration = expiration
  end

  def conn(client_integrity = nil)
    headers = {
      "Content-Type" => "application/json",
      "Client-ID" => Setting.twitch(:client_id)
    }

    headers["Client-Integrity"] = client_integrity unless client_integrity.nil?

    Faraday.new(
      url: "https://gql.twitch.tv",
      headers: headers
    )
  end
end
