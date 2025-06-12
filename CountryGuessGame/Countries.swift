import Foundation

/// Alphabetically sorted list of localized country names
let allCountries: [String] =
  Locale.isoRegionCodes
    .compactMap { Locale.current.localizedString(forRegionCode: $0) }
    .sorted()
