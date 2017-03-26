module Bot
  module Database
    class Expansion
      include NoBrainer::Document

      field :name, unique: true, required: true
      field :authors

      has_many :questions
      has_many :answers

      def card_count
        questions.count + answers.count
      end
    end

    class Question
      include NoBrainer::Document

      field :text, required: true
      field :answers, type: Integer, default: 1

      belongs_to :expansion, index: true

      def print
        text.gsub(/_/) { '\_\_\_' }
      end

      def substitute(answers)
        if text.scan(/_/).count.zero?
          "#{text} `#{answers.first.text}`"
        else
          text.gsub(/_/) { "`#{answers.shift.text}`" }
        end
      end
    end

    class Answer
      include NoBrainer::Document

      field :text, required: true

      belongs_to :expansion, index: true
    end
  end
end
