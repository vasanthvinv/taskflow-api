module Api
  module V1
    class BoardsController < ApplicationController
      before_action :set_board, only: %i[show update destroy]

      def index
        boards = current_user.boards.includes(:lists)
        render json: boards.map { |b| board_json(b) }
      end

      def show
        render json: board_json(@board, full: true)
      end

      def create
        board = current_user.boards.build(board_params)
        if board.save
          render json: board_json(board), status: :created
        else
          render json: { errors: board.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @board.update(board_params)
          render json: board_json(@board)
        else
          render json: { errors: @board.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @board.destroy
        head :no_content
      end

      private

      def set_board
        @board = current_user.boards.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Board not found' }, status: :not_found
      end

      def board_params
        params.permit(:title, :description, :color)
      end

      def board_json(board, full: false)
        data = { id: board.id, title: board.title, description: board.description,
                 color: board.color, lists_count: board.lists.size,
                 created_at: board.created_at }
        if full
          data[:lists] = board.lists.includes(:cards).map do |list|
            { id: list.id, title: list.title, position: list.position,
              cards: list.cards.map { |c| card_json(c) } }
          end
        end
        data
      end

      def card_json(card)
        { id: card.id, title: card.title, description: card.description,
          position: card.position, due_date: card.due_date, label: card.label }
      end
    end
  end
end
