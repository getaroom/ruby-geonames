module Geonames
  class Error < ::StandardError
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

    ERROR_CLASSES = {
      10 => AuthorizationException,
      11 => RecordDoesNotExist,
      12 => OtherError,
      13 => DatabaseTimeout,
      14 => InvalidParameter,
      15 => NoResultFound,
      16 => DuplicateException,
      17 => PostalCodeNotFound,
      18 => DailyLimitExceeded,
      19 => HourlyLimitExceeded,
      20 => WeeklyLimitExceeded,
      21 => InvalidInput,
      22 => ServerOverloadedException,
      23 => ServiceNotImplemented
    }.freeze

    def self.from_code(code, msg)
      klass = ERROR_CLASSES.fetch(code, Unknown)
      klass.new(msg)
    end
  end
end
