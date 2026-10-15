import Foundation

#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

enum Network {
    /// The first non-loopback IPv4 address, so a phone on the same network can open the preview.
    static func lanAddress() -> String? {
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0, let first = interfaces else { return nil }
        defer { freeifaddrs(interfaces) }

        return sequence(first: first, next: { $0.pointee.ifa_next }).lazy.compactMap { pointer -> String? in
            let interface = pointer.pointee
            guard let address = interface.ifa_addr, address.pointee.sa_family == sa_family_t(AF_INET),
                  (interface.ifa_flags & UInt32(IFF_LOOPBACK)) == 0,
                  (interface.ifa_flags & UInt32(IFF_UP)) != 0 else { return nil }
            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let length = socklen_t(MemoryLayout<sockaddr_in>.size)
            let resolved = getnameinfo(address, length, &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
            return resolved == 0 ? String(cString: host) : nil
        }.first
    }
}

enum Browser {
    /// The command that opens `url` in the default browser on this platform.
    static func openCommand(for url: String) -> [String] {
        #if os(macOS)
        return ["open", url]
        #else
        return ["xdg-open", url]
        #endif
    }
}
