module Api
  module V1
    class CardsController < ApplicationController
      before_action :set_list, only: %i[create]
      before_action :set_card, only: %i[update destroy]

      def create
        card = @list.cards.build(card_params.merge(user: current_user))
        card.position = @list.cards.maximum(:position).to_i + 1
        if card.save
          render json: card_json(card), status: :created
        else
          render json: { errors: card.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if params[:list_id_target].present?
          target_list = List.joins(:board).find_by!(id: params[:list_id_target], boards: { user_id: current_user.id })
          @card.list = target_list
          @card.position = target_list.cards.maximum(:position).to_i + 1
        end
        if @card.update(card_params)
          render json: card_json(@card)
        else
          render json: { errors: @card.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @card.destroy
        head :no_content
      end

      private

      def set_list
        @list = List.joins(:board).find_by!(id: params[:list_id], boards: { user_id: current_user.id })
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'List not found' }, status: :not_found
      end

      def set_card
        @card = Card.joins(list: :board).find_by!(id: params[:id], boards: { user_id: current_user.id })
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Card not found' }, status: :not_found
      end

      def card_params
        params.permit(:title, :description, :position, :due_date, :label, :list_id)
      end

      def card_json(card)
        { id: card.id, title: card.title, description: card.description,
          position: card.position, due_date: card.due_date, label: card.label,
          list_id: card.list_id }
      end
    end
  end
end
