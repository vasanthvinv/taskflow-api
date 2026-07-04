module Api
  module V1
    class ListsController < ApplicationController
      before_action :set_board
      before_action :set_list, only: %i[update destroy]

      def create
        list = @board.lists.build(list_params)
        list.position = @board.lists.maximum(:position).to_i + 1
        if list.save
          render json: list_json(list), status: :created
        else
          render json: { errors: list.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @list.update(list_params)
          render json: list_json(@list)
        else
          render json: { errors: @list.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @list.destroy
        head :no_content
      end

      private

      def set_board
        @board = current_user.boards.find(params[:board_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Board not found' }, status: :not_found
      end

      def set_list
        @list = @board.lists.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'List not found' }, status: :not_found
      end

      def list_params
        params.permit(:title, :position)
      end

      def list_json(list)
        { id: list.id, title: list.title, position: list.position, board_id: list.board_id }
      end
    end
  end
end
