export class UsersService {
  async findByPhone(phone: string) {
    return {
      id: 'stub-user-id',
      phone,
      role: null,
    };
  }
}
