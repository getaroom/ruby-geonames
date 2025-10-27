module Geonames
  class Error < ::StandardError
    def self.from_code(code, msg)
        klass = case code
                when 10
                  AuthorizationException
                when 11
                  RecordDoesNotExist
                when 12
                  OtherError
                 when 13
                   DatabaseTimeout
                 when 14
                   InvalidParameter
                 when 15
                   NoResultFound
                 when 16
                   DuplicateException
                 when 17
                   PostalCodeNotFound
                 when 18
                   DailyLimitExceeded
                 when 19
                   HourlyLimitExceeded
                 when 20
                   WeeklyLimitExceeded
                 when 21
                   InvalidInput
                 when 22
                   ServerOverloadedException
                 when 23
                   ServiceNotImplemented
                else
                    Unknown
                end
       klass.new(msg)
     end
     class AuthorizationException < Error; end
     class RecordDoesNotExist < Error; end
     class OtherError < Error; end
     class DatabaseTimeout < Error; end
     class InvalidParameter < Error; end
     class NoResultFound < Error; end
     class DuplicateException < Error; end
     class PostalCodeNotFound < Error; end
     class DailyLimitExceeded < Error; end
     class HourlyLimitExceeded < Error; end
     class WeeklyLimitExceeded < Error; end
     class InvalidInput < Error; end
     class ServerOverloadedException < Error; end
     class ServiceNotImplemented < Error; end
     class Unknown < Error; end
   end
end
