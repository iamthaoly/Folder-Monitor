//
//  NSDateExtension.swift

// import UIKit
import Foundation

extension Date {
    static func currentDateTime() -> String {
        let dateFormater = DateFormatter()
        dateFormater.timeZone = .current
        dateFormater.dateFormat = "yyyy-MM-dd hh:mm"
        let str = dateFormater.string(from: Date())
        return str
    }
    func dateTimeFormat() -> String {
        let description = self.description.components(separatedBy: " ")
        return description[0] + " " + description[1]
    }
    func getStrDate() -> String {
        let description = self.description.components(separatedBy: " ")
        return description[0]
    }
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let result = formatter.string(from: self)
        return result
    }
}

extension Date {

    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    var nextMonth: Date? {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)
    }
    var nextWeek: Date? {
        return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self)
    }
    var nextYear: Date? {
        return Calendar.current.date(byAdding: .year, value: 1, to: self)
    }
    var nextForever: Date? {
        return Calendar.current.date(byAdding: .year, value: 99, to: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    /**
     "yyyy-MM-dd"
     */
    public func getStrDateFromFormat(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let result = formatter.string(from: self)
        return result
    }
    public func getDetailDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let result = formatter.string(from: self)
        return result
    }

    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
 }
extension DateFormatter {
    public func timeFromStrDate(dateString: String, oldFormat: String, newFormat: String) -> String {
        self.dateFormat = oldFormat// "EEE MMM d"
        let dateObj = self.date(from: dateString)
        if dateObj == nil {
            return "00 : 00 PM"
        } else {
            self.dateFormat = newFormat// "yyyy-MM-dd"
            debugPrint(self.calendar.component(.hour, from: dateObj!))
            return "\(self.calendar.component(.hour, from: dateObj!)) : \(self.calendar.component(.minute, from: dateObj!))"
        }
    }

    public func convertStrDate(dateString: String, oldFormat: String, newFormat: String) -> String {
        self.dateFormat = oldFormat// "EEE MMM d"
        let dateObj = self.date(from: dateString)
        if dateObj == nil {
            return dateString
        } else {
            self.dateFormat = newFormat// "yyyy-MM-dd"
            return self.string(from: dateObj!)
        }
    }
    /**
     Return today, tomorrow, yesterday
     */
    public func strDateFromStrDate(dateString: String, oldFormat: String, newFormat: String) -> String {
        self.dateFormat = oldFormat// "EEE MMM d"
        let dateObj = self.date(from: dateString)

        if let schedulePlay = dateObj {

            if NSCalendar.current.isDateInToday(schedulePlay) == true {
                return "Today"
            }

            if NSCalendar.current.isDateInTomorrow(schedulePlay) == true {
                return "Tomorrow"
            }
            if NSCalendar.current.isDateInYesterday(schedulePlay) == true {
                return "Yesterday"
            }
        }
        if dateObj == nil {
            return dateString
        } else {
            self.dateFormat = newFormat// "yyyy-MM-dd"

            return self.string(from: dateObj!)
        }

    }

    public func getLocalTimeFrom(dateUTC: String, timeUTC: String) {
        // create dateFormatter with UTC time format
        self.dateFormat = "yyyy-MM-dd hh:mm:ss"
        self.timeZone = NSTimeZone.init(name: "UTC")! as TimeZone
        let strUTC = dateUTC + timeUTC
        let date = self.date(from: strUTC)

        self.timeZone = TimeZone.current
        let timeStamp = self.string(from: date!)

        debugPrint(timeStamp)

    }

}
