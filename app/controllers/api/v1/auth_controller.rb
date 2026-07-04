module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[register login]

      def register
        user = User.new(user_params)
        if user.save
          create_sample_board(user)
          token = JwtService.encode(user_id: user.id)
          render json: { user: user_json(user), token: token }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email].to_s.downcase)
        if user&.authenticate(params[:password])
          token = JwtService.encode(user_id: user.id)
          render json: { user: user_json(user), token: token }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def me
        render json: { user: user_json(current_user) }
      end

      private

      def user_params
        params.permit(:name, :email, :password, :password_confirmation)
      end

      def user_json(user)
        { id: user.id, name: user.name, email: user.email }
      end

      def create_sample_board(user)
        board = user.boards.create!(title: 'My First Board', description: 'Your workspace — drag cards, add labels, set due dates.', color: '#7c3aed')

        sample = [
          {
            title: 'To Do',
            cards: [
              { title: 'Read the README', label: 'feature', description: 'Check out how TaskFlow works and explore all the features.' },
              { title: 'Create your first card', label: nil, description: 'Click "+ Add card" at the bottom of any list.' },
              { title: 'Set a due date on a card', label: 'review', description: 'Click a card to open it and pick a date from the sidebar.' },
            ]
          },
          {
            title: 'In Progress',
            cards: [
              { title: 'Try drag & drop', label: 'urgent', description: 'Drag this card to "Done" when you\'re finished testing.' },
              { title: 'Add a new list', label: nil, description: 'Click "Add list" at the end of the board.' },
            ]
          },
          {
            title: 'Done',
            cards: [
              { title: 'Sign up for TaskFlow ✓', label: 'feature', description: 'You made it! Welcome aboard.' },
            ]
          },
        ]

        sample.each_with_index do |list_data, li|
          list = board.lists.create!(title: list_data[:title], position: li + 1)
          list_data[:cards].each_with_index do |card_data, ci|
            list.cards.create!(
              title:       card_data[:title],
              description: card_data[:description],
              label:       card_data[:label],
              position:    ci + 1,
              user:        user
            )
          end
        end
      end
    end
  end
end
