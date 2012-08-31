module Utils
  module Teams
    class FileCart
      attr_accessor :buy_ids, :sale_ids

      def initialize
        self.buy_ids = []
        self.sale_ids = []
      end

      def buy_player club_file
        buy_ids << club_file.id
      end

      def sell_player temp_file
        sale_ids << temp_file.id
      end

      def cancel_buy club_file
        buy_ids.delete club_file.id
      end

      def cancel_sell team_file
        sale_ids.delete team_file.id
      end

      def buy_files
        ClubFile.active.current.where(id: buy_ids)
      end

      def sale_files
        TeamFile.current.where(id: sale_ids)
      end
    end
  end
end
